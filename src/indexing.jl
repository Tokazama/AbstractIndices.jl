getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i...) where {T,N}
    maybe_indicesarray(a,
                       getindex(parent(a), to_indices(a, i)...),
                       _drop_empty(map(getindex, axes(a), i)))
end

function Base.getindex(a::AbstractIndicesArray{T,1}, i::Any) where T
    @boundscheck checkbounds(a, i)
    @inbounds _getindex(a, parent(a), axes(a), (i,))
end

# if a single value is used for indexing then we assume it's linear indexing
# and goes straight to the parent structure.
function Base.getindex(a::AbstractIndicesArray{T,N}, i::Any) where {T,N}
    @boundscheck checkbounds(parent(a), i)
    @inbounds getindex(parent(a), i)
end

function _getindex(
    A::AbstractIndicesArray,
    a::AbstractArray,
    axs::Tuple{Vararg{<:AbstractIndex,N}},
    i::Tuple{Vararg{Any,N}}
   ) where {N}

    maybe_indicesarray(A,
                       a[to_indices(A, i)...],
                       _drop_empty(map(getindex, axs, i)))
end

function maybe_indicesarray(
    A::AbstractIndicesArray,
    newarray::AbstractArray,
    axs::Tuple
   )

    similar_type(A, typeof(axs), typeof(newarray))(newarray, axs)
end

maybe_indicesarray(::AbstractIndicesArray, a::Any, axs::Tuple{}) = a


function _drop_empty(x::Tuple)
    if length(first(x)) > 1
        (first(x), _drop_empty(tail(x))...)
    else
        _drop_empty(tail(x))
    end
end

_drop_empty(x::Tuple{}) = ()
