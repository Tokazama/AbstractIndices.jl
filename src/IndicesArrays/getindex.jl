Base.getindex(a::IndicesArray{T,N}, i::Colon) where {T,N} = a

@propagate_inbounds function Base.getindex(a::IndicesVector, i)
    return _unsafe_getindex(a, parent(a), to_index(axes(a, 1), i))
end

@propagate_inbounds function Base.getindex(a::IndicesArray{T,N}, i...) where {T,N}
    return _unsafe_getindex(a, parent(a), to_indices(a, i))
end

function _unsafe_getindex(::T, a::AbstractArray, inds::Integer) where {T}
    @inbounds(getindex(a, inds))
end

function _unsafe_getindex(::T, a::AbstractArray, inds::AbstractIndex) where {T}
    return rebuild(T, @inbounds(getindex(a, inds)), inds)
end

function _unsafe_getindex(::T, a::AbstractArray, inds::Tuple{Vararg{Int}}) where {T}
    return @inbounds(getindex(a, inds...))
end

function _unsafe_getindex(::T, a::AbstractArray, inds::Tuple) where {T}
    return rebuild(T, @inbounds(getindex(a, values.(inds)...)), _drop_empty(inds))
end

_drop_empty(x::Tuple{Any,Vararg}) = (first(x), _drop_empty(tail(x))...)
_drop_empty(x::Tuple{<:Integer,Vararg}) = _drop_empty(tail(x))
_drop_empty(x::Tuple{}) = ()
