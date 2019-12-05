@inline @propagate_inbounds function Base.to_index(a::AbstractIndex, i)
    return _to_index(index_by(a, i), a, i)
end

# _to_index
# TODO find_all should be filter where possible
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i::Function)
    return __to_index(a, i, find_all(i, keys(a)))
end
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i::AbstractVector)
    return __to_index(a, i, find_all(in(i), keys(a)))
end
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i)
    return __to_index(a, i, find_first(==(i), keys(a)))
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i::Function)
    return __to_index(a, i, find_all(i, values(a)))
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i)
    @boundscheck if !checkindex(Bool, values(a), i)
        throw(BoundsError(a, i))
    end
    return @inbounds getindex(values(a), i)
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i::AbstractVector)
    @boundscheck if !checkindex(Bool, values(a), i)
        throw(BoundsError(a, i))
    end
    return @inbounds unsafe_reindex(a, i)
end

# __to_index
@propagate_inbounds function __to_index(a, i, idx::T) where {T<:Union{Integer,Nothing}}
    @boundscheck if T <: Nothing
        throw(BoundsError(a, i))
    end
    return @inbounds getindex(values(a), idx)
end
@propagate_inbounds function __to_index(a, i, idx::AbstractVector{T}) where {T<:Union{Integer,Nothing}}
    @boundscheck if !(T<:Integer)
        throw(BoundsError(a, i))
    end
    return unsafe_reindex(a, idx)
end

#=
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{name,K},
    f::Function
   ) where {name,K}
    return _to_index(a, f, find_all(f, keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{name,K},
    i::K
   ) where {name,K}
    return _to_index(a, i, find_first(==(i), keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{name,K},
    i::AbstractVector{K}
   ) where {name,K}
    return _to_index(a, i, find_all(in(i), keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{name,K},
    i::AbstractUnitRange{K}
   ) where {name,K}
    return _to_index(a, i, find_all(in(i), keys(a)))
end

for I in (Int,CartesianIndex{1})
    @eval begin
        # to_index
        @propagate_inbounds function Base.to_index(a::AbstractIndex{name,$I}, i::$I) where {name}
            return _to_index(a, i, find_first(==(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{name,$I},
            i::AbstractVector{$I}
           ) where {name}
            return _to_index(a, i, find_all(in(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{name,$I},
            i::AbstractUnitRange{$I}
           ) where {name}
            return _to_index(a, i, find_all(in(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{name,K},
            i::$I
           ) where {name,K}
            return _to_index(a, i, find_first(==(i), values(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{name,K},
            i::AbstractVector{$I}
           ) where {name,K}
            return _to_index(a, i, find_all(in(i), values(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{name,K},
            i::AbstractUnitRange{$I}
           ) where {name,K}
            return _to_index(a, i, find_all(in(i), values(a)))
        end
    end
end

_to_index(a, i, inds::Integer) = inds
_to_index(a, i, inds::AbstractVector{T}) where {T<:Integer} = unsafe_reindex(a, inds)

=#
"""
    reindex()
"""
function reindex(a::AbstractIndex, inds::AbstractVector)
    @boundscheck checkbounds(a, inds)
    return unsafe_reindex(a, inds)
end

"""
    unsafe_reindex()
"""
function unsafe_reindex(a::AbstractIndex, inds::AbstractVector)
    return similar_type(a)(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))

_reindex(a::UnitRange{T}, inds) where {T} = UnitRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitMRange{T}, inds) where {T} = UnitMRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitSRange{T}, inds) where {T} = UnitSRange{T}(first(a), first(a) + length(inds) - 1)
