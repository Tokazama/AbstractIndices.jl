

###
### Index
###
#=
@propagate_inbounds function Base.getindex(a::AbstractIndex, i::AbstractUnitRange)
    @boundscheck checkbounds(a, i)
    return to_index(a, i)
end

@propagate_inbounds function Base.getindex(a::AbstractIndex, i)
    @boundscheck checkbounds(a, i)
    return to_index(a, i)
end
=#

###
### IndicesArray
###
Base.getindex(a::IndicesArray{T,N}, i::Colon) where {T,N} = a

@propagate_inbounds function Base.getindex(a::IndicesVector, i)
    return _unsafe_getindex(parent(a), to_index(axes(a, 1), i))
end

@propagate_inbounds function Base.getindex(a::IndicesArray{T,N}, i...) where {T,N}
    return _unsafe_getindex(parent(a), to_indices(a, i))
end

_unsafe_getindex(a::AbstractArray, inds::Integer) = @inbounds(getindex(a, inds))

function _unsafe_getindex(a::AbstractArray, inds::AbstractIndex)
    return IndicesArray(@inbounds(getindex(a, inds)), inds)
end

function _unsafe_getindex(a::AbstractArray, inds::Tuple{Vararg{Int}})
    return @inbounds(getindex(a, inds...))
end

function _unsafe_getindex(a::AbstractArray, inds::Tuple)
    return IndicesArray(@inbounds(getindex(a, values.(inds)...)), _drop_empty(inds))
end

_drop_empty(x::Tuple{Any,Vararg}) = (first(x), _drop_empty(tail(x))...)
_drop_empty(x::Tuple{<:Integer,Vararg}) = _drop_empty(tail(x))
_drop_empty(x::Tuple{}) = ()
