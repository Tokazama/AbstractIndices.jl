function Base.reduce(f, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return rebuild(a, reduce(f, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

function Base.mapreduce(f, op, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return rebuild(a, mapreduce(f, op, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

function Base.mapslices(f, a::IndicesArray; dims, kwargs...)
    d = to_dims(a, dims)
    return rebuild(a, mapslices(f, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

