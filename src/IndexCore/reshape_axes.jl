"""
    reshape_axes(a, dims)
    reshape_axes(a, dims...)
"""
reshape_axes(x::AbstractArray, dims::Integer...) = reshape_axes(x, Tuple(dims))
reshape_axes(x::Tuple, dims::Integer...) = _reshape_axes(x, Tuple(dims))

reshape_axes(x::AbstractArray, dims::Tuple) = _reshape_axes(axes(x), dims)
reshape_axes(x::Tuple, dims::Tuple) = _reshape_axes(x, dims)

function _reshape_axes(axs::Tuple{Any,Vararg}, dims::Tuple{Integer,Vararg})
    (reshape_axis(first(axs), first(dims)), _reshape_axes(tail(axs), tail(dims))...)
end
_reshape_axes(axs::Tuple{}, dims::Tuple{}) = ()

"""
    reshape_axis(x::AbstractUnitRange, len) -> AbstractUnitRange
"""
function reshape_axis(x, len::Integer)
    if  length(x) > len
        return set_length(x, len)
    elseif length(x) < len
        return set_length(x, len)
    else  # length(x) == len
        return copy(x)
    end
end

