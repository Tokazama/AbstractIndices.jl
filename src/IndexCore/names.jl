dimnames(::AbstractIndex{name}) where {name} = name
dimnames(::AbstractUnitRange) = nothing
dimnames(x::AbstractArray) = dimnames(axes(x))
dimnames(x::AbstractArray, i::Int) = dimnames(axes(x, i))
dimnames(x::Tuple{Any,Vararg}) = (dimnames(first(x)), dimnames(tail(x))...)
dimnames(x::Tuple{}) = ()

combine_names(a::Union{Symbol,Nothing}, b::AbstractIndex) = combine_names(a, dimnames(b))
combine_names(a::AbstractIndex, b::Union{Symbol,Nothing}) = combine_names(dimnames(a), b)
combine_names(a::AbstractIndex, b::AbstractIndex) = combine_names(dimnames(a), dimnames(b))

combine_names(a::Symbol, b::Symbol) = a
combine_names(::Nothing, b::Symbol) = b
combine_names(a::Symbol, ::Nothing) = a
combine_names(::Nothing, ::Nothing) = nothing

"""
    to_dims(a, names::Tuple) -> NTuple{N,Int}
    to_dims(a, names) -> Int
"""
@inline function to_dims(a::AbstractArray, names::Tuple{Any,Vararg})
    return (to_dims(a, first(names)), to_dims(a, tail(names))...)
end
to_dims(a::AbstractArray, names::Tuple{}) = ()

to_dims(a::AbstractArray, d::Union{Int,Colon}) = d
to_dims(a::AbstractArray, d::Integer) = Int(d)
@inline function to_dims(a::AbstractArray{T,N}, name::Symbol) where {T,N}
    for i in 1:N
        dimnames(a, i) === name && return i
    end
    return 0
end

function to_dims(dnames::Tuple, name::Symbol)::Int
    dimnum = _to_dim(dnames, name)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(name))) does not match any dimension name ($dnames)"
        ))
    end
    return dimnum
end
to_dims(dnames::Tuple, d::Union{Int,Colon}) = d
to_dims(dnames::Tuple, d::Integer) = Int(d)

function _to_dim(dnames::NTuple{N}, name::Symbol) where N
    for ii in 1:N
        getfield(dnames, ii) === name && return ii
    end
    return 0
end

"""
    unname(x)

Remove the name from a `x`. If `x` doesn't have a name the same instance of `x`
is returned.
"""
unname(x) = x
unname(nt::NamedTuple{names}) where {names} = Tuple(nt)
unname(x::Tuple) = unname.(x)

