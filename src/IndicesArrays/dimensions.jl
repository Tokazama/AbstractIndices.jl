function Base.dropdims(a::IndicesArray; dims)
    d = to_dims(a, dims)
    return rebuild(a, dropdims(parent(a); dims=d), drop_axes(a, dims=d))
end

function Base.reshape(a::IndicesArray, dims)
    d = to_dims(a, dims)
    return rebuild(a, reshape(parent(a), d), reshape_axes(a, d))
end

Base.selectdim(a::IndicesArray, d, i) = selectdim(a, to_dims(nda, d), i)

function Base.permutedims(a::IndicesArray, p)
    return rebuild(a, permutedims(parent(a), p), permute_axes(a, p))
end
function Base.permutedims(a::IndicesArray, p...)
    return rebuild(a, permutedims(parent(a), p...), permute_axes(a, p...))
end

for f in (
    :(Base.transpose),
    :(Base.adjoint),
    :(Base.permutedims),
    :(LinearAlgebra.pinv))

    # Vector
    @eval function $f(a::IndicesVector)
        return rebuild(a, $f(parent(a)), (axes(a, 1), axes(a, 1)))
    end

    # Vector Double Transpose
    if f !== :(Base.permutedims)
        @eval begin
            function $f(a::Union{IndicesAdjoint,IndicesTranspose})
                return rebuild(a, $f(parent(a)), (axes(a, 2),))
            end
        end
    end

    # Matrix
    @eval function $f(a::IndicesMatrix)
        return rebuild(a, $f(parent(a)), (axes(a, 2), axes(a, 1)))
    end
end

Base.inv(a::IndicesMatrix) = rebuild(a, inv(parent(a)), inv_axes(a))

function Base.eachslice(a::IndicesArray; dims, kwargs...)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return _maybe_indarray(slice, reduce_axes(a, d))
    end
end
