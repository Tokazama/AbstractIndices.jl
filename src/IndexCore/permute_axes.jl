"""
    permute_axes(x::AbstractArray, p::Tuple) = permute_axes(axes(x), p)
    permute_axes(x::NTuple{N}, p::NTuple{N}) -> NTuple{N}

Returns indices of `a` in the order of `perms`.
"""
permute_axes(x::AbstractArray{T,N}, p::NTuple{N}) where {T,N} = permute_axes(axes(x), p)
permute_axes(x::NTuple{N}, p::NTuple{N,Any}) where {N} = permute_axes(x, to_dims(x, p))
permute_axes(x::NTuple{N}, p::NTuple{N,Int}) where {N} = map(i -> getfield(x, i), p)


