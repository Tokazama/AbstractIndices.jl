function Base.promote_shape(a::Tuple{Vararg{Union{AbstractUnitRange,NamedUnitRangeIndex,UnitRangeIndex}}},
                       b::Tuple{Vararg{Union{AbstractUnitRange,NamedUnitRangeIndex,UnitRangeIndex}}})
    if length(a) < length(b)
        return promote_shape(b, a)
    end
    for i=1:length(b)
        if a[i] != b[i]
            throw(DimensionMismatch("dimensions must match"))
        end
    end
    for i=length(b)+1:length(a)
        if a[i] != 1:1
            throw(DimensionMismatch("dimensions must match"))
        end
    end
    return a
end
