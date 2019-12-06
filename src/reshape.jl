Base.reshape(a::IndicesArray, dims) = _reshape(a, to_dims(a, dims))
_reshape(a, d) = IndicesArray(reshape(parent(a), d), reshape_axes(a, d))

