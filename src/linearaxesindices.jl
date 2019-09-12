"""
    LinearAxesIndices

# Exampls

```jldoctest
julia> li = LinearAxesIndices(1:2, 1:3, 1:4)

julia>
```
"""
struct LinearAxesIndices{N,A} <: AbstractIndicesArray{Int,N,A,LinearIndices{N,NTuple{N,OneTo{Int}}}}
    axes::A
    indices::LinearIndices{N,NTuple{N,OneTo{Int}}}
end

Base.axes(lai::LinearAxesIndices) = getproperty(lai, :axes)

Base.parent(lai::LinearAxesIndices) = getproperty(lai, :indices)

LinearAxesIndices(a...) = LinearAxesIndices(Tuple(a))

function LinearAxesIndices(axes::Tuple{Vararg{<:OneToIndex}})
    LinearAxesIndices{length(axes),typeof(axes)}(axes, LinearIndices(to_index.(axes)))
end

function LinearAxesIndices(axes::Tuple)
    LinearAxesIndices(map(asindex, axes, map(i->OneTo(length(i)), axes)))
end


