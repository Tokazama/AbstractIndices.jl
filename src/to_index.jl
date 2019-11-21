@propagate_inbounds function Base.to_index(
    a::AbstractIndex{K},
    f::Function
   ) where {K}
    return _to_index(a, f, find_all(f, keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{K},
    i::K
   ) where {K}
    return _to_index(a, i, find_first(==(i), keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{K},
    i::AbstractVector{K}
   ) where {K}
    return _to_index(a, i, find_all(==(i), keys(a)))
end
@propagate_inbounds function Base.to_index(
    a::AbstractIndex{K},
    i::AbstractUnitRange{K}
   ) where {K}
    return _to_index(a, i, find_all(==(i), keys(a)))
end

for I in (Int,CartesianIndex{1})
    @eval begin
        # to_index
        @propagate_inbounds function Base.to_index(a::AbstractIndex{$I}, i::$I)
            return _to_index(a, i, find_first(==(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{$I},
            i::AbstractVector{$I}
           )
            return _to_index(a, i, find_all(in(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{$I},
            i::AbstractUnitRange{$I}
           )
            return _to_index(a, i, find_all(in(i), keys(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{K},
            i::$I
           ) where {K}
            return _to_index(a, i, find_first(==(i), values(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{K},
            i::AbstractVector{$I}
           ) where {K}
            return _to_index(a, i, find_all(in(i), values(a)))
        end
        @propagate_inbounds function Base.to_index(
            a::AbstractIndex{K},
            i::AbstractUnitRange{$I}
           ) where {K}
            return _to_index(a, i, find_all(in(i), values(a)))
        end
    end
end

_to_index(a, i, inds) = inds
_to_index(a, i, inds::AbstractVector{Union{Any,Nothing}}) =  BoundsError(a, i)
_to_index(a, i, inds::Nothing) = BoundsError(a, i)
