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
_to_index(a, i, inds::AbstractUnitRange) = unsafe_reindex(a, inds)
_to_index(a, i, inds::AbstractVector{Union{Any,Nothing}}) =  BoundsError(a, i)
_to_index(a, i, inds::Nothing) = BoundsError(a, i)


"""
    reindex()
"""
function reindex(a::AbstractIndex, inds::AbstractUnitRange)
    @boundscheck checkbounds(a, inds)
    return unsafe_reindex(a, inds)
end

"""
    unsafe_reindex()
"""
function unsafe_reindex(a::AbstractIndex, inds::AbstractRange)
    return similar_type(a)(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end

_reindex(a::OneTo{T}, inds::AbstractRange) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds::AbstractRange) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds::AbstractRange) where {T} = OneToSRange{T}(length(inds))

_reindex(a::UnitRange{T}, inds::AbstractRange) where {T} = UnitRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitMRange{T}, inds::AbstractRange) where {T} = UnitMRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitSRange{T}, inds::AbstractRange) where {T} = UnitSRange{T}(first(a), first(a) + length(inds) - 1)

