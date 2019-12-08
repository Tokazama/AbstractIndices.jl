"""
    inverse_axes(a::AbstractMatrix) = inverse_axes(axes(a))
    inverse_axes(a::Tuple{I1,I2}) -> Tuple{I2,I1}

Returns the inverted axes of `a`, corresponding to the `inv` method from the 
`LinearAlgebra` package in the standard library.

## Examples
```jldoctest
julia> inverse_axes((Index{:a}(1:4), Index{:b}(1:4)))
(Index{b}(1:4 => Base.OneTo(4)), Index{a}(1:4 => Base.OneTo(4)))
```
"""
inverse_axes(x::AbstractMatrix) = inverse_axes(axes(x))
inverse_axes(x::Tuple{I1,I2}) where {I1,I2} = (last(x), first(x))

