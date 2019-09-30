function Base.merge(a::AbstractIndex, b::AbstractIndex, args...; kwargs...)
    asindex(
        merge_keys(a, b, args...; kwargs...),
        merge_values(a, b, args...; kwargs...),
        merge_names(a, b, args...; kwargs...)
       )
end

"""
    merge_keys(a, b)
"""
merge_keys(a::AbstractIndex, b::AbstractIndex, args...; kwargs...) = merge_keys(keys(a), keys(b), args...; kwargs...)
merge_keys(a::AbstractVector{T} , b::AbstractVector{T}) where {T} = unique(a, b)
merge_keys(a::Tuple{Vararg{T}}  , b::AbstractVector{T}) where {T} = unique(a, b)
merge_keys(a::AbstractVector{T} , b::Tuple{Vararg{T}} ) where {T} = unique(a, b)
merge_keys(a::Tuple{Vararg{T}}  , b::Tuple{Vararg{T}} ) where {T} = (unique(a, b)...,)

"""
    merge_values(a, b)
"""
merge_values(a::AbstractIndex, b::AbstractIndex, args...; kwargs...) = merge_values(values(a), values(b), args...; kwargs...)
merge_values(a::AbstractUnitRange{T1}, b::AbstractUnitRange{T2}) where {T1,T2} = merge_values(promote(a, b)...)
merge_values(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where {T} = a > b ? a : b


"""
    merge_names(a, b)
"""
@inline merge_names(a::AbstractIndex, b::AbstractIndex) = merge_names(dimnames(a), dimnames(b))
merge_names(a::Nothing, b::Symbol) = b
merge_names(a::Symbol, b::Nothing) = a
merge_names(a::Nothing, b::Nothing) = nothing
function merge_names(a::Symbol, b::Symbol)
    if a === b
        return a
    else
        Symbol("merge(", a, ",", b, ")")
    end
end

@inline function Base.merge(method::Symbol, a::AbstractIndex...)
    if method === :inner
        innermerge(a...)
    elseif method === :left
        leftmerge(a...)
    elseif method === :right
        rightmerge(a...)
    elseif method === :outer
        outermerge(a...)
    else
        error("Join method must be one of :inner, :left, :right, :outer")
    end
end

innermerge(a::AbstractIndex...) = intersect(a...)

outermerge(a::AbstractIndex...) = union(axes...)

leftmerge(a::AbstractIndex...) = first(a)

rightmerge(a::AbstractIndex...) = last(a)
