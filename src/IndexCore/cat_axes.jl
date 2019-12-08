"""
    vcat_axes(x, y) -> Tuple

Returns the appropriate axes for `vcat(x, y)`.

## Examples
```
julia> vcat_axes((Index{:a}(1:2), Index{:b}(1:4)), (Index{:z}(1:2), Index(1:4)))
(Index{a}(1:4 => Base.OneTo(4)), Index{b}(1:4 => Base.OneTo(4)))

julia> a, b = [1 2 3 4 5], [6 7 8 9 10; 11 12 13 14 15];

julia> vcat_axes(a, b) == axes(vcat(a, b))
true
"""
vcat_axes(x::AbstractArray, y::AbstractArray) = vcat_axes(axes(x), axes(y))
function vcat_axes(x::Tuple, y::Tuple)
    return (cat_axis(first(x), first(y)), combine_indices(tail(x), tail(y))...)
end

"""
    hcat_axes(x, y) -> Tuple

Returns the appropriate axes for `hcat(x, y)`.

## Examples
```
julia> hcat_axes((Index{:a}(1:4), Index{:b}(1:2)), (Index{:z}(1:4), Index(1:2)))
(Index{a}(1:4 => Base.OneTo(4)), Index{b}(1:4 => Base.OneTo(4)))

julia> a, b = [1; 2; 3; 4; 5], [6 7; 8 9; 10 11; 12 13; 14 15]

julia> hcat_axes(a, b) == axes(hcat(a, b))
true
"""
hcat_axes(x::AbstractArray, y::AbstractArray) = hcat_axes(axes(x), axes(y))
function hcat_axes(x::Tuple, y::Tuple)
    return (combine_index(first(x), first(y)), vcat_axes(tail(x), tail(y))...)
end
hcat_axes(x::NTuple{1,Any}, y::NTuple{1,Any}) = _hcat_axes(combine_index(first(x), first(y)))
_hcat_axes(x) = (x, set_length(unname(x), 2))

"""
    cat_axes(x, y, dims) -> Tuple

Returns the appropriate axes for `cat(x, y; dims)`. If any of `dims` are names
then they should refer to the dimensions of `x`.

## Examples
```
julia> cat_axes((Index{:a}(1:4), Index{:b}(1:2)), (Index{:z}(1:4), Index(1:2)), (:a, :b))
(Index{a}(1:8 => Base.OneTo(8)), Index{b}(1:4 => Base.OneTo(4)))
"""

"""
    cat_axis(x, y)

Returns the concatenation of the axes `x` and `y`. New subtypes of
`AbstractIndex` must implement a unique `cat_axis` method.
"""
function cat_axis(x::Index, y)
    return Index{cat_names(x, y)}(cat_keys(x, y), cat_values(x, y))
end
function cat_axis(x::SimpleIndex, y)
    return SimpleIndex{cat_names(x, y)}(cat_keys(x, y), cat_values(x, y))
end
cat_axis(x, y) = cat_values(x, y)

"""
    cat_keys(x, y)
"""
cat_keys(x, y) = _cat_keys(keys(x), y)
_cat_keys(x, y) = __cat_keys(Continuity(x), x, y)
__cat_keys(::ContinuousTrait, x, y) = set_length(x, length(x) + length(y))
__cat_keys(::DiscreteTrait, x, y) = make_unique(x, keys(y))

"""
    cat_values(x, y)

Returns the appropriate values of and index within the operation `vcat_axis(x, y)`

See also: [`cat_axis`](@ref)
"""
cat_values(x::AbstractIndex, y) = cat_values(values(x), y)
cat_values(x::AbstractRange, y) = set_length(x, length(x) + length(y))

"""
    cat_names(x, y)

Returns the combined name of `x` and `y` for calls to `cat`. Default behavior is
the same as `combine_names(x, y)`.

See also: [`combine_names`](@ref)
"""
cat_names(x, y) = combine_names(x, y)
