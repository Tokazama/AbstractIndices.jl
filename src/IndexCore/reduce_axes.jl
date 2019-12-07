"""
    reduce_axes(a, dims)

Returns the appropriate axes for a measure that reduces dimensions along the
dimensions `dims`.

## Example
```
julia> reduce_axes((Index{:a}(1:4), Index{:b}(1:4)), 2)
(Index{a}(1:4 => Base.OneTo(4)), Index{b}(1:1 => Base.OneTo(1)))

julia> reduce_axes((Index{:a}(1:4), Index{:b}(1:4)), :a)
(Index{a}(1:1 => Base.OneTo(1)), Index{b}(1:4 => Base.OneTo(4)))
```
"""
reduce_axes(x::AbstractArray, dims) = reduce_axes(axes(x), dims)
reduce_axes(x, dims) = _reduce_axes(x, to_dims(x, dims))
reduce_axes(x, dims::Colon) = ()
_reduce_axes(x::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduce_axes(axs, (dims,))
function _reduce_axes(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i -> ifelse(in(i, dims), reduce_axis(axs[i]), axs[i]), 1:D))
end

"""
    reduce_axis(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)

See also: [`reduce_axes`](@ref)

## Example
```
julia> reduce_axis(Index{:a}(1:4))
Index{a}(1:1 => Base.OneTo(1))

julia> reduce_axis(1:4)
1:1
```
"""
function reduce_axis(x::AbstractIndex)
    if isempty(x)
        error("Cannot reduce empty index.")
    else
        return unsafe_reindex(x, 1:1)
    end
end
reduce_axis(x::OneTo{T}) where {T} = OneTo(one(T))
reduce_axis(x::OneToSRange{T}) where {T} = OneToSRange(one(T))
reduce_axis(x::OneToMRange{T}) where {T} = OneToMRange(one(T))
reduce_axis(x::UnitRange{T}) where {T} = UnitRange{T}(one(T), one(T))
reduce_axis(x::UnitSRange{T}) where {T} = UnitSRange{T}(one(T), one(T))
reduce_axis(x::UnitMRange{T}) where {T} = UnitMRange{T}(one(T), one(T))
