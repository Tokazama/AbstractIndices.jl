"""
    covcor_axes(x, dim) -> NTuple{2}

Returns appropriate axes for a `cov` or `var` method on array `x`.

## Examples
```jldoctest
julia> covcor_axes((Index{:a}(1:4), Index{:b}(1:4)), 2)
(Index{a}(1:4 => Base.OneTo(4)), Index{a}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Index{:a}(1:4), Index{:b}(1:4)), :b)
(Index{a}(1:4 => Base.OneTo(4)), Index{a}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Index{:a}(1:4), Index{:b}(1:4)), 1)
(Index{b}(1:4 => Base.OneTo(4)), Index{b}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Index{:a}(1:4), Index{:b}(1:4)), :a)
(Index{b}(1:4 => Base.OneTo(4)), Index{b}(1:4 => Base.OneTo(4)))
```
"""
covcor_axes(x::AbstractMatrix, dim) = _covcor_axes(axes(x), to_dims(x, dim))
covcor_axes(x::NTuple{2,Any}, dim) = _covcor_axes(x, to_dims(x, dim))
_covcor_axes(x::NTuple{2,Any}, dim::Int) = dim === 1 ? (x[2], x[2]) : (x[1], x[1])

