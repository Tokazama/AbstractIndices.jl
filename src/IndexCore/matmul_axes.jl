"""
    matmul_axes(a, b) -> Tuple

Returns the appropriate axes for the return of `a * b` where `a` and `b` are a
vector or matrix.

## Examples
```jldoctest
julia> axs2, axs1 = (Index{:b}(1:10), Index(1:10)), (Index{:a}(1:10),);

julia> matmul_axes(axs2, axs2)
(Index{b}(1:10 => Base.OneTo(10)), Index(1:10 => Base.OneTo(10)))

julia> matmul_axes(axs1, axs2)
(Index{a}(1:10 => Base.OneTo(10)), Index(1:10 => Base.OneTo(10)))

julia> matmul_axes(axs2, axs1)
(Index{b}(1:10 => Base.OneTo(10)),)

julia> matmul_axes(axs1, axs1)
()
```
"""
matmul_axes(a::AbstractArray,  b::AbstractArray ) = matmul_axes(indices(a), indices(b))
matmul_axes(a::Tuple{Any},     b::Tuple{Any,Any}) = (first(a), last(b))
matmul_axes(a::Tuple{Any,Any}, b::Tuple{Any,Any}) = (first(a), last(b))
matmul_axes(a::Tuple{Any,Any}, b::Tuple{Any}    ) = (first(a),)
matmul_axes(a::Tuple{Any},     b::Tuple{Any}    ) = ()

