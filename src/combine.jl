function combine_axes(A::Tuple{<:AbstractIndex, Vararg{Any}}, B::Tuple{<:AbstractIndex, Vararg{Any}})
    (combine(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function combine_axes(A::Tuple{<:AbstractIndex, Vararg{Any}},
                      B::Tuple{Any, Vararg{Any}})
    (combine(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function combine_axes(A::Tuple{Any, Vararg{Any}},
                      B::Tuple{<:AbstractIndex, Vararg{Any}})
    (combine(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function combine_axes(A::Tuple{}, B::Tuple{<:AbstractIndex, Vararg{Any}})
    (combine(first(B))..., combine_axes(A, tail(B))...)
end

function combine_axes(A::Tuple{<:AbstractIndex, Vararg{Any}}, B::Tuple{})
    (combine(first(A))..., combine_axes(tail(A), B)...)
end

# TODO: N-dimensional concatenation
"""
    combine(a, b)

Combines two subtypes of `AbstractIndex` for broadcasting.
"""
@inline function combine(a, b, args...; kwargs...)
    vs = combine_values(a, b, args...; kwargs...)
    if length(vs) == 1
        return ()
    else
        return (asindex(combine_keys(a, b, args...; kwargs...), vs, combine_names(a, b, args...; kwargs...)),)
    end
end

@inline function combine(a, args...; kwargs...)
    vs = combine_values(a, args...; kwargs...)
    if length(vs) == 1
        return ()
    else
        return (asindex(combine_keys(a, args...; kwargs...), vs, combine_names(a, args...; kwargs...)),)
    end
end

"""
    combine_keys(a, b)

Combines the keys of `a` and `b` for broadcasting. Bey default `combine_keys`
calls `combine_keys(keys(a), keys(b))`. Users who want unique behavior for
combining a new `AbstractIndex` subtype or returned key type should specialize
at this level.
"""
combine_keys(a::AbstractIndex, b::AbstractIndex, args...; kwargs...) = combine_keys(keys(a), keys(b), args...; kwargs...)
combine_keys(a::TupOrVec, b::AbstractIndex, args...; kwargs...) = combine_keys(a, keys(b), args...; kwargs...)
combine_keys(a::AbstractIndex, b::TupOrVec, args...; kwargs...) = combine_keys(keys(a), b, args...; kwargs...)
#combine_keys(a::TupOrVec{K}, b::TupOrVec{K}) where {K} = unique((a..., b...))
combine_keys(a::TupOrVec, b::TupOrVec) = length(a) > length(b) ? a : b
combine_keys(a::TupOrVec) = a


"""
    combine_names(a, b)

Combines the names of `a` and `b` into `<a's name>-<b's name>`. If one of them
has no name then the name of the other is returned. If neither have a name then
`nothing` is returned.
"""
combine_names(a::TupOrVec, b::TupOrVec, args...; kwargs...) = combine_names(dimnames(a), dimnames(b), args...; kwargs...)
function combine_names(a::Union{Symbol,Nothing}, b::TupOrVec, args...; kwargs...)
    combine_names(a, dimnames(b), args...; kwargs...)
end
function combine_names(a::TupOrVec, b::Union{Symbol,Nothing}, args...; kwargs...)
    combine_names(dimnames(a), b, args...; kwargs...)
end
combine_names(a::Nothing, b::Symbol) = b
combine_names(a::Symbol, b::Nothing) = a
combine_names(a::Nothing, b::Nothing) = nothing
function combine_names(a::Symbol, b::Symbol)
    if a === b
        return a
    else
        Symbol(a, :-, b)
    end
end
combine_names(a) = dimnames(a)

# TODO combine_values doesn't currently account for offset indices
"""
    combine_values(a, b)

"""
function combine_values(a::AbstractIndex, b::AbstractIndex, args...; kwargs...)
    combine_values(values(a), values(b), args...; kwargs...)
end
function combine_values(a::AbstractIndex, b::TupOrVec, args...; kwargs...)
    combine_values(values(a), b, args...; kwargs...)
end
function combine_values(a::TupOrVec, b::AbstractIndex, args...; kwargs...)
    combine_values(a, values(b), args...; kwargs...)
end
combine_values(a::TupOrVec{T1}, b::TupOrVec{T2}) where {T1,T2} = combine_values(promote(a, b)...)
combine_values(a::A, b::A) where {A<:TupOrVec} = a > b ? a : b
combine_values(a) = a


# FIXME this extends an internal undocumented function function
#Base.Broadcast.axistype(a::AbstractIndex, b::Any) = combine(a, b)
#Base.Broadcast.axistype(a::Any, b::AbstractIndex) = combine(a, b)
#Base.Broadcast.axistype(a::AbstractIndex, b::AbstractIndex) = combine(a, b)

