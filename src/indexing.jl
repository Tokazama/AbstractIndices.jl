###
### to_index: bounds are checked already
###
###
### getindex(::AbstractIndex, ::Any)
###

###
### to_indices
###
function Base.to_indices(
    A,
    inds::Tuple{AbstractIndex, Vararg{Any}},
    I::Tuple{Any, Vararg{Any}}
   )
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

function Base.to_indices(
    A,
    inds::Tuple{AbstractIndex, Vararg{Any}},
    I::Tuple{Colon, Vararg{Any}}
   )
    Base.@_inline_meta
    (values(first(inds)), to_indices(A, maybetail(inds), tail(I))...)
end

function Base.to_indices(
    A,
    inds::Tuple{AbstractIndex, Vararg{Any}},
    I::Tuple{CartesianIndex{1}, Vararg{Any}}
   )
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

function Base.to_indices(A, I::Tuple{Union{AbstractIndex,AbstractPosition}})
    Base.@_inline_meta
    to_indices(A, axes(A), I)
end


###
### AbstractIndex getindex
###

function getindex(A::AbstractArray{T,N}, i::Vararg{AbstractIndex,N}) where {T,N}
    getindex(A, to_indices(A, i))
end

Base.LinearIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = LinearIndices(values.(axs))

Base.CartesianIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = CartesianIndices(values.(axs))

Base.Slice(x::AbstractIndex) = Base.Slice(values(x))

function Base.getindex(a::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V}
    @boundscheck checkindex(Bool, a, i)
    return values(i)
end

# fall back to the value/index when indexing a non AbstractIndex
#function Base.getindex(a::AbstractArray, i::AbstractPosition)
#    @boundscheck checkindex(Bool, a, values(i))
#    @inbounds getindex(a, values(i))
#end
#const Union{AbstractPosition,Symbol,Colon,AbstractVector}

#function Base.getindex(a::AbstractArray, i::Vararg{})
#    @boundscheck checkindex(Bool, a, values(i))
#    @inbounds getindex(a, values(i))
#end


@inline function Base.:(==)(a::AbstractPosition, b::AbstractPosition)
    isequal(parent(a), parent(b)) & isequal(positionstate(a), positionstate(b))
end


getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i::CartesianIndex{N}) where {T,N}
    getindex(parent(a), i)
end

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
