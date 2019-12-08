"""
    append_axes(x, y)

Returns the axes for `append(x, y)`.
"""
append_axes(x::AbstractVector, y::AbstractVector) = (append_axis(axes(x, 1), axes(y, 1)),)


"""
    append_axis(x, y)

Returns the appended axes `x` and `y`. New subtypes of `AbstractIndex` must
implement a unique `append_axis` method.

## Examples
```jldoctest
julia> using AbstractIndices: append_axis!

julia> x, y = Index(UnitMRange(1, 10)), SimpleIndex(UnitMRange(1, 10));

julia> append_axis(x, y)
Index(UnitMRange(1:20) => OneToMRange(20))

julia> append_axis(y, x)
SimpleIndex(UnitMRange(1:20))
```
"""
function append_axis(x::Index, y::Index)
    return Index{combine_names(x, y)}(append_keys(x, y), append_values(x, y))
end
function append_axis(x::SimpleIndex, y::SimpleIndex)
    return SimpleIndex{append_names(x, y)}(append_values(x, y))
end
append_axis(x::AbstractIndex, y::AbstractVector) = append_axis(promote(x, y)...)
append_axis(x::AbstractVector, y::AbstractIndex) = append_axis(promote(x, y)...)

"""
    append_keys(x, y)

Returns the appropriate keys of and index within the operation `append_axis(x, y)`

See also: [`append_axis`](@ref)
"""
append_keys(x, y) = cat_keys(x, y)

"""
    append_values(x, y)

Returns the appropriate values of and index within the operation `append_axis(x, y)`

See also: [`append_axis`](@ref)
"""
append_values(x, y) = cat_values(x, y)

"""
    append_axes!(x, y)

Returns the axes for `append!(x, y)`.
"""
append_axes!(x::AbstractVector, y::AbstractVector) = (append_axis!(axes(x, 1), axes(y, 1)),)

"""
    append_axis!(x, y)

Returns the appended axes `x` and `y`. New subtypes of `AbstractIndex` must
implement a unique `append_axis!` method.

## Examples
```jldoctest
julia> using AbstractIndices: append_axis!

julia> x, y = Index(UnitMRange(1, 10)), SimpleIndex(UnitMRange(1, 10));

julia> append_axis!(x, y)
Index(UnitMRange(1:20) => OneToMRange(20))

julia> append_axis!(y, x)
SimpleIndex(UnitMRange(1:30))
```
"""
function append_axis!(x::Index, y)
    _append_keys!(keys(x), y)
    set_length!(values(x), length(x) + length(y))
    return x
end
function append_axis!(x::SimpleIndex, y)
    set_length!(x, length(x) + length(y))
    return x
end

_append_keys!(x, y) = __append_keys!(Continuity(x), x, y)
__append_keys!(::ContinuousTrait, x, y) = set_length!(x, length(x) + length(y))
__append_keys!(::DiscreteTrait, x, y) = make_unique!(x, keys(y))

