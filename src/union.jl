
function union(a::AbstractIndex, b::AbstractIndex, args...; kwargs...)
    asindex(
        union_keys(a, b),
        union_values(a, b),
        union_names(a, b)
       )
end

"""
    union_keys(a, b)
"""
union_keys(a::AbstractIndex, b::AbstractIndex) = union_keys(keys(a), keys(b))
union_keys(a::AbstractVector{T}, b::AbstractVector{T}) where {T} = union(a, b)
union_keys(a::Tuple{Vararg{T}}, b::AbstractVector{T}) where {T} = union(a, b)
union_keys(a::AbstractVector{T}, b::Tuple{Vararg{T}}) where {T} = union(a, b)
union_keys(a::Tuple{Vararg{T}}, b::Tuple{Vararg{T}}) where {T} = Tuple(union(a, b))


"""
    union_values(a, b)
"""
union_values(a::AbstractIndex, b::AbstractIndex, args...; kwargs...) = union_values(values(a), values(b), args...; kwargs...)
union_values(a::AbstractUnitRange{T1}, b::AbstractUnitRange{T2}) where {T1,T2} = union_values(promote(a, b)...)
union_values(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where {T} = a > b ? a : b

"""
    union_names(a, b)
"""
@inline union_names(a::AbstractIndex, b::AbstractIndex) = union_names(dimnames(a), dimnames(b))
union_names(a::Nothing, b::Symbol) = b
union_names(a::Symbol, b::Nothing) = a
union_names(a::Nothing, b::Nothing) = nothing
function union_names(a::Symbol, b::Symbol)
    if a === b
        return a
    else
        Symbol("union(", a, ",", b, ")")
    end
end


