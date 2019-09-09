"""
    asindex(axis[, index])

Chooses the most appropriate index type for an axis and index set.

# Examples
```jldoctest axisindex_examples
julia> float_offset = asindex(2.0:11.0)

julia> float_offset[3.0]  # 3.0 is the 2nd position in the axis field, return 2nd position in the index field
2
```

If the input doesn't match the `axis`'s element type then indexing falls back
to default `Int` based indexing.
```jldoctest axisindex_examples
julia> float_offset[3]  # 3 isn't in found in the axis field. return 3rd position in the index field
3
```

If the `axis` field has `Int` elements then indexing with an `Int` will never
bypass the `axis`.
```jldoctest axisindex_examples
julia> int_offset = asindex(2:11, 1:10);

julia> int_offset[3]
2
```

It's also possible to use a tuple of `Symbol`s to represent a vector.
```jldoctest
julia> symbol_index = asindex((:one, :two, :three))

julia> symbol_index[:one]
1

julia> symbol_index[:three]
3
```
"""
asindex(axis::AbstractVector, index::AbstractVector) = AxisIndex(axis, index)

asindex(axis::AbstractVector, ::OneTo) = OneToIndex(axis)

asindex(axis::NTuple{N}) where {N} = asindex(axis, OneTo(N))

asindex(axis::NTuple{N,Symbol}, index::AbstractVector) where {N} = LabelIndex(axis, index)

function asindex(axis::NTuple{N,T}, index::AbstractVector) where {N,T}
    if isbitstype(T)
        LabelIndex(axis, index)
    else
        asindex([axis...])
    end
end

asindex(axis::AbstractVector) = asindex(axis, axes(axis, 1))
