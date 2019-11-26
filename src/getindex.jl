###
### Index
###
@propagate_inbounds function Base.getindex(a::AbstractIndex, i::Function)
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(a::AbstractIndex{K}, i::K) where {K}
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(
    a::AbstractIndex{K},
    i::AbstractVector{K}
   ) where {K}
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(
    a::AbstractIndex{K},
    i::AbstractUnitRange{K}
   ) where {K}
    return _getindex(a, to_index(a, i))
end

for I in (Int,CartesianIndex{1})
    @eval begin
        # getindex
        @propagate_inbounds function Base.getindex(a::AbstractIndex{$I}, i::$I)
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{$I}, i::AbstractVector{$I})
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{$I}, i::AbstractUnitRange{$I})
            return _getindex(a, to_index(a, i))
        end

        @propagate_inbounds function Base.getindex(a::AbstractIndex{K}, i::$I) where {K}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{K}, i::AbstractVector{$I}) where {K}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{K}, i::AbstractUnitRange{$I}) where {K}
            return _getindex(a, to_index(a, i))
        end
    end
end

function _getindex(a::AbstractIndex, inds::AbstractUnitRange{Integer})
    return similar_type(a)(@inbounds(keys(a)[inds]), @inbounds(values(a)[inds]), AllUnique, true)
end

_getindex(a::AbstractIndex, inds::Integer) = @inbounds(getindex(values(a), inds))

###
### IndicesArray
###
Base.getindex(a::IndicesArray{T,N}, i::Colon) where {T,N} = a

Base.getindex(a::IndicesVector, i) = _unsafe_getindex(parent(a), (to_index(axes(a, 1), i),))

@propagate_inbounds function Base.getindex(a::IndicesArray{T,N}, i...) where {T,N}
    return _unsafe_getindex(parent(a), to_indices(a, i))
end

function _unsafe_getindex(a::AbstractArray{T,N}, inds::NTuple{N,Int}) where {T,N}
    return @inbounds(getindex(a, inds...))
end

function _unsafe_getindex(a::AbstractArray{T,N}, inds::Tuple) where {T,N}
    return IndicesArray(@inbounds(getindex(a, inds...)), _drop_empty(inds))
end

#_drop_empty(x::Tuple{Colon,Vararg}) = 
function _drop_empty(x::Tuple{Any,Vararg})
    if length(first(x)) > 1
        (first(x), _drop_empty(tail(x))...)
    else
        _drop_empty(tail(x))
    end
end
_drop_empty(x::Tuple{}) = ()

