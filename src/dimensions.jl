function Base.eachslice(a::IndicesArray; dims, kwargs...)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return _maybe_array_reduce(slice, reduce_indices(a, d))
    end
end

Base.selectdim(a::IndicesArray, d, i) = selectdim(a, to_dims(nda, d), i)
