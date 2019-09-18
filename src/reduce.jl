
function Base.mapreduce(a::AbstractIndicesArray)
end

mapreduce(f, op, A::AbstractArray; dims=:, kw...) = _mapreduce_dim(f, op, kw.data, A, dims)
mapreduce(f, op, A::AbstractArray...; kw...) = reduce(op, map(f, A...); kw...)

_mapreduce_dim(f, op, nt::NamedTuple{(:init,)}, A::AbstractArray, ::Colon) = mapfoldl(f, op, A; nt...)

_mapreduce_dim(f, op, ::NamedTuple{()}, A::AbstractArray, ::Colon) = _mapreduce(f, op, IndexStyle(A), A)

_mapreduce_dim(f, op, nt::NamedTuple{(:init,)}, A::AbstractArray, dims) =
    mapreducedim!(f, op, reducedim_initarray(A, dims, nt.init), A)

_mapreduce_dim(f, op, ::NamedTuple{()}, A::AbstractArray, dims) =
    mapreducedim!(f, op, reducedim_init(f, op, A, dims), A)


reduce(op, A::AbstractArray; kw...) = mapreduce(identity, op, A; kw...)

sum(A::AbstractArray; dims)

sum!(r, A)

prod(A::AbstractArray; dims)

prod!(A::AbstractArray; dims)


maximum(A::AbstractArray; dims)


maximum!(r, A)


minimum(A::AbstractArray; dims)

minimum!(A::AbstractArray; dims)
