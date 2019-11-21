"""
    drop_indices(a; dims)
    drop_indices(a, dims)

Returns tuple of indices that don't include `dims`.
"""
drop_indices(a; dims) = drop_indices(a, dims)
drop_indices(a, dims) = _drop_indices(axes(a), dims)

_drop_indices(a, dim::Integer) = _drop_indices(a, (Int(dim),))
function _drop_indices(axs::Tuple{Vararg{<:Any,D}}, dims::NTuple{N,Int}) where {D,N}
    for i in 1:N
        1 <= dims[i] <= D || throw(ArgumentError("dropped dims must be in range 1:ndims(A)"))
        for j = 1:i-1
            dims[j] == dims[i] && throw(ArgumentError("dropped dims must be unique"))
        end
    end
    d = ()
    for (i,axisi) in zip(1:D,axs)
        if !in(i, dims)
            d = tuple(d..., axisi)
        end
    end
    return d
end

"""
    permute_indices(a, perms)

Returns axes of `a` in the order of `perms`.
"""
permute_indices(a, perms) = permute_indices(axes(a), perms)
function permute_indices(a::NTuple{N}, perms::NTuple{N,Int}) where {N}
    return map(i -> getfield(a, i), perms)
end

@inline Base.dropdims(a::IndicesArray; dims) = _ddims(a, to_dims(a, dims))
_ddims(a, d) = IndicesArray(dropdims(parent(a); dims=d), dropaxes(a, dims=d))


@inline Base.permutedims(a::IndicesArray, perm) = _pdims(a, to_dims(a, perm))
_pdims(a, d) = IndicesArray(permutedims(parent(a), d), permuteaxes(a, d))

@inline Base.reshape(a::IndicesArray, dims) = _reshape(a, to_dims(a, dims))
_reshape(a, d) = IndicesArray(reshape(parent(a), d), reshape_indices(a, d))

function Base.eachslice(a::IndicesArray; dims, kwargs...)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return _maybe_array_reduce(slice, reduce_indices(a, d))
    end
end

for f in (
    :(Base.transpose),
    :(Base.adjoint),
    :(Base.permutedims),
    :(LinearAlgebra.pinv))

    # Vector
    @eval function $f(a::IndicesVector)
        return IndicesArray($f(parent(a)), (axes(a, 1), axes(a, 1)), AllUnique, LengthChecked)
    end

    # Vector Double Transpose
    if f !== :permutedims
        @eval begin
            function $f(a::Union{IndicesAdjoint,IndicesTranspose})
                return IndicesArray($f(parent(a)), (axes(a, 2),), AllUnique)
            end
        end
    end

    # Matrix
    @eval function $f(a::IndicesMatrix)
        return IndicesArray($f(parent(a)), (axes(a, 2), axes(a, 1)), AllUnique)
    end
end

Base.selectdim(a::IndicesArray, d, i) = selectdim(a, to_dims(nda, d), i)
