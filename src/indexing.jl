function Base.getindex(ai::AbstractIndex, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds to_index(ai, i)
end

Base.getindex(x::AbstractIndex, i::Colon) = x



#= TODO think about what makes sense for setting in indices
function Base.setindex!(ai::AxisIndex, val::Any, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds setindex!(to_index(ai), val, to_index(ai, i))
end
=#

"""
    setaxis!(A::AxisIndex, val, i)

The equivalent of `setindex` for the axis values of `A`.
"""
function setaxis!(ai::AbstractIndex, val::Any, i::Any)
    @boundscheck checkbounds(to_axis(ai), i)
    @inbounds setindex!(to_axis(ai), val, to_index(to_axis(ai), i))
end

"""
    canindex(a::AxisIndex, b::AbstractVector) -> Bool

Determines if the `index` of `a` is appropriate for indexing `b`.

# Examples
```jldoctest
julia> canindex(AxisIndex(2:11, Base.OneTo(10)), Base.OneTo(10))
true

julia> canindex(AxisIndex(2:11, Base.OneTo(10)), AxisIndex(2:11, Base.OneTo(10)))
false

```
"""
canindex(a::AxisIndex, b::AxisIndex) = _canindex(index(a), axis(b))

canindex(a::AxisIndex, b::AbstractVector) = _canindex(index(a), axes(b, 1))

function _canindex(a::AbstractRange{T}, b::AbstractRange{T}) where {T}
    first(a) == first(b) && step(a) == step(b) && last(a) == last(b)
end

function _canindex(a::AbstractVector{T}, b::AbstractVector{T}) where {T}
    out = true
    for (a_i,b_i) in zip(a,b)
        out &= (a_i === b_i)
    end
    return out & (length(b) == length(b))
end

_canindex(a::AbstractVector{Ta}, b::AbstractVector{Tb}) where {Ta,Tb} = false

Base.getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i::CartesianIndex{N}) where {T,N}
    getindex(parent(a), to_indices(a, i.I))
end

function Base.getindex(a::AbstractIndicesArray{T,1}, i::Any) where T
    @boundscheck checkbounds(a, i)
    @inbounds getindex(parent(a), to_index(axes(a, 1), i))
end

function Base.getindex(a::AbstractIndicesArray{T,N}, i::Vararg{Any,N}) where {T,N}
    @boundscheck checkbounds(a, i...)
    @inbounds maybe_indicesarray(a, getindex(parent(a), to_indices(a, axes(a), i)...), i)
end

function Base.getindex(a::AbstractIndicesVector, i::Any)
    maybe_indicesarray(a, getindex(parent(a), to_index(a, i)), i)
end

function maybe_indicesarray(a::AbstractIndicesArray{T}, p::AbstractArray{T}, inds::Tuple) where T
    IndicesArray(p, to_axes(a, inds))
end

maybe_indicesarray(a::AbstractIndicesArray{T}, p::T, inds) where T = p
