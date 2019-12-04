
to_dim(a::IndicesArray, dim::Union{Int,Symbol}) = to_dim(axes(a), dim)

function to_dim(axs::Tuple, dim::Union{Int,Symbol})
    d = _to_dim(axs, dim)
    if d === 0
        error("$dim is not a known dimension.")
    end
    return d
end

function _to_dim(axs::Tuple{Vararg{Any,N}}, d::Int) where {N}
    for i in 1:N
        i === d && return i
    end
    return 0
end
function _to_dim(axs::Tuple{Vararg{Any,N}}, d::Symbol) where {N}
    for i in 1:N
        _match_names(axs[i], d) && return i
    end
    return 0
end
_match_names(::AbstractIndex{name}, n::Symbol) where {name} = name === n

to_dims(a::AbstractArray, dims) = to_dims(axes(a), (dims,))
to_dims(a::AbstractArray{T,N}, dims::Colon) where {T,N} = ntuple(i -> i, Val(N))
to_dims(a::AbstractArray, dims::Tuple) = to_dims(axes(a), dims)
to_dims(axs::Tuple, dims::Tuple) = map(d_i -> to_dim(axs, d_i), dims)

