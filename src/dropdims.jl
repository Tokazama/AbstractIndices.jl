"""
    drop_axes(a; dims)
    drop_axes(a, dims)

Returns tuple of indices that don't include `dims`.
"""
drop_axes(a; dims) = drop_axes(a, dims)
drop_axes(a, dims) = _drop_axes(axes(a), dims)

_drop_axes(a, dim::Integer) = _drop_axes(a, (Int(dim),))
function _drop_axes(axs::Tuple{Vararg{<:Any,D}}, dims::NTuple{N,Int}) where {D,N}
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


@inline Base.dropdims(a::IndicesArray; dims) = _dropdims(a, to_dims(a, dims))
function _dropdims(a, d)
    return IndicesArray(
        dropdims(parent(a); dims=d),
        drop_axes(a, dims=d),
        AllUnique,
        LengthChecked
       )
end
