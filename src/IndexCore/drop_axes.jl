"""
    drop_axes(a, dims)

Returns tuple of indices that don't include `dims`.
"""
drop_axes(x::AbstractArray, dims) = drop_axes(axes(x), dims)
drop_axes(x::Tuple, dims) = _drop_axes(x, to_dims(x, dims))

_drop_axes(x, dims::Tuple) = __drop_axes(x, dims)
_drop_axes(x, dims) = __drop_axes(x, (dims,))

function __drop_axes(axs::Tuple{Vararg{<:Any,D}}, dims::NTuple{N}) where {D,N}
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
