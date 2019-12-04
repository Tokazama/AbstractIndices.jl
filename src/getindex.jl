

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

@propagate_inbounds function Base.getindex(a::AbstractIndex, i::AbstractUnitRange{<:Integer})
    return to_index(a, i)
end
@propagate_inbounds Base.getindex(a::AbstractIndex, i::Integer) = to_index(a, i)
@propagate_inbounds Base.getindex(a::AbstractIndex, i) = to_index(a, i)


#=
function _getindex(a::AbstractIndex, inds::AbstractUnitRange{Integer})
    return similar_type(a)(@inbounds(keys(a)[inds]), @inbounds(values(a)[inds]), AllUnique, true)
end

_getindex(a::AbstractIndex, inds::Integer) = @inbounds(getindex(values(a), inds))

@propagate_inbounds function Base.getindex(
    a::AbstractIndex{name,K},
    i::AbstractVector{K}
   ) where {name,K}
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(
    a::AbstractIndex{name,K},
    i::AbstractUnitRange{K}
   ) where {name,K}
    return _getindex(a, to_index(a, i))
end

for I in (Int,CartesianIndex{1})
    @eval begin
        # getindex
        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,$I}, i::$I) where {name}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,$I}, i::AbstractVector{$I}) where {name}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,$I}, i::AbstractUnitRange{$I}) where {name}
            return _getindex(a, to_index(a, i))
        end

        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,K}, i::$I) where {name,K}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,K}, i::AbstractVector{$I}) where {name,K}
            return _getindex(a, to_index(a, i))
        end
        @propagate_inbounds function Base.getindex(a::AbstractIndex{name,K}, i::AbstractUnitRange{$I}) where {name,K}
            return _getindex(a, to_index(a, i))
        end
    end
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

