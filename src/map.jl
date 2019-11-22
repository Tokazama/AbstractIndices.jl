@inline map(f, a1::IndicesArray, as::AbstractArray...) = _map(f, a1, as...)
@inline function map(f, a1::AbstractArray, a2::IndicesArray, as::AbstractArray...)
    return _map(f, a1, a2, as...)
end
@inline function map(f, a1::IndicesArray, a2::IndicesArray, as::AbstractArray...)
    return _map(f, a1, a2, as...)
end

@generated function _map(f, a::AbstractArray...)
    first_staticarray = findfirst(ai -> ai <: StaticArray, a)
    if first_staticarray === nothing
        return :(throw(ArgumentError("No StaticArray found in argument list")))
    end
    # Passing the Size as an argument to _map leads to inference issues when
    # recursively mapping over nested StaticArrays (see issue #593). Calling
    # Size in the generator here is valid because a[first_staticarray] is known to be a
    # StaticArray for which the default Size method is correct. If wrapped
    # StaticArrays (with a custom Size method) are to be supported, this will
    # no longer be valid.
    S = Size(a[first_staticarray])

    if prod(S) == 0
        # In the empty case only, use inference to try figuring out a sensible
        # eltype, as is done in Base.collect and broadcast.
        # See https://github.com/JuliaArrays/StaticArrays.jl/issues/528
        eltys = [:(eltype(a[$i])) for i ∈ 1:length(a)]
        return quote
            @_inline_meta
            S = same_size(a...)
            T = Core.Compiler.return_type(f, Tuple{$(eltys...)})
            @inbounds return similar_type(a[$first_staticarray], T, S)()
        end
    end

    exprs = Vector{Expr}(undef, prod(S))
    for i ∈ 1:prod(S)
        tmp = [:(a[$j][$i]) for j ∈ 1:length(a)]
        exprs[i] = :(f($(tmp...)))
    end

    return quote
        @_inline_meta
        S = same_size(a...)
        @inbounds elements = tuple($(exprs...))
        @inbounds return similar_type(typeof(_first(a...)), eltype(elements), S)(elements)
    end
end

@inline function map!(f, dest::IndicesArray, a::IndicesArray...)
    return _map!(f, dest, same_size(dest, a...), a...)
end

# Ambiguities with Base:
@inline function map!(f, dest::IndicesArray, a::IndicesArray)
    _map!(f, dest, same_size(dest, a), a)
end
@inline function map!(f, dest::IndicesArray, a::IndicesArray, b::IndicesArray)
    _map!(f, dest, same_size(dest, a, b), a, b)
end


@generated function _map!(f, dest, ::Size{S}, a::StaticArray...) where {S}
    exprs = Vector{Expr}(undef, prod(S))
    for i ∈ 1:prod(S)
        tmp = [:(a[$j][$i]) for j ∈ 1:length(a)]
        exprs[i] = :(dest[$i] = f($(tmp...)))
    end
    return quote
        @_inline_meta
        @inbounds $(Expr(:block, exprs...))
    end
end
