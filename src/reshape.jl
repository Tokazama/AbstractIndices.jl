"""
    reshape_indices(a, dims)
    reshape_indices(a, dims...)
"""
reshape_indices(a, dims::Integer...) = reshape_indices(a, Tuple(dims))
reshape_indices(a, dims::Tuple) = _reshape_indices(axes(a), dims)
function _reshape_indices(axs::Tuple{Any,Vararg}, dims::Tuple{Integer,Vararg})
    (reshape_index(first(axs), first(dims)), _reshape_indices(tail(axs), tail(dims))...)
end
_reshape_indices(axs::Tuple{}, dims::Tuple{}) = ()

"""
    reshape_index(a, len)
"""
function reshape_index(axs, i::Int)
    if length(axs) == i
        return copy(axs)
    elseif length(axs) > i
        return shrink_last(axs, i)
    elseif length(axs) < i
        return grow_last(axs, i)
    end
end

Base.reshape(a::IndicesArray, dims) = _reshape(a, to_dims(a, dims))
_reshape(a, d) = IndicesArray(reshape(parent(a), d), reshape_indices(a, d))

