
Base.has_offset_axes(::OneToIndex) = false
Base.has_offset_axes(::StaticKeys) = false
Base.has_offset_axes(a::AbstractIndex) = !isone(firstindex(a))
###
### to_index
###
to_index(a::AbstractIndex{K,V}, i::K) where {K,V} = getindex(values(a), _to_index(keys(a), i))

# ketype is not Int so assume user wants to directly go to index
to_index(a::AbstractIndex{K,V}, i::Int) where {K,V} = getindex(values(a), i)

# keytype is Int so assume user is interfacing to index through the axis
to_index(a::AbstractIndex{Int,V}, i::Int) where {K,V} = getindex(values(a), _to_index(keys(a), i))

to_index(a::AbstractIndex{K,V}, i::CartesianIndex{1}) where{K,V} = getindex(values(a), i)

to_index(a::AbstractIndex{K,V}, inds::TupOrVec{K}) where {K,V} = getindex(values(a), _to_index(keys(a), inds))

to_index(a::AbstractIndex{Int,V}, inds::TupOrVec{Int}) where {V} = getindex(values(a), _to_index(keys(a), inds))

to_index(a::AbstractIndex{K,V}, inds::TupOrVec{Int}) where {K,V} = getindex(values(a), inds)

to_index(a::AbstractIndex{K,V}, inds::Colon) where {K,V} = values(a)

_to_index(k::AbstractVector{K}, i::K) where {K} = findfirst(isequal(i), k)
function _to_index(k::NTuple{N,K}, idx::K) where {N,K}
    for i in 1:N
        getfield(k, i) === idx && return i
    end
    return 0
end

_to_index(k::TupOrVec, inds::TupOrVec) = map(i -> _to_index(k, i), inds)

# TODO double check this
function _to_index(k::AbstractRange, inds::AbstractRange)
    findfirst(isequal(first(inds)), k):round(Integer, step(inds) / step(k)):findfirst(isequal(last(inds)), k)
end

to_index(a::AbstractVector, i::AbstractIndex) = getindex(a, values(i))


###
### AbstractIndex getindex
###
function Base.getindex(a::AbstractIndex, i::Any)
    @boundscheck checkindex(Bool, a, i)
    @inbounds to_index(a, i)
end

Base.getindex(a::AbstractIndex, i::Colon) = a

function getindex(A::AbstractArray{T,N}, i::Vararg{AbstractIndex,N}) where {T,N}
    getindex(A, to_indices(A, i))
end

Base.LinearIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = LinearIndices(values.(axs))

Base.CartesianIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = CartesianIndices(values.(axs))

Base.Slice(x::AbstractIndex) = Base.Slice(values(x))

###
### AbstractIndicesArray getindex
###

Base.getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i::CartesianIndex{N}) where {T,N}
    getindex(parent(a), i)
end

function Base.getindex(a::AbstractIndicesArray{T,1}, i::Any) where T
    @boundscheck checkbounds(a, i)
    @inbounds _getindex(typeof(a), parent(a), axes(a), i)
end

# if a single value is used for indexing than we assume it's linear indexing
# and goes straight to the parent structure.
function Base.getindex(a::AbstractIndicesArray{T,N}, i::Any) where {T,N}
    @boundscheck checkbounds(parent(a), i)
    @inbounds getindex(parent(a), i)
end


function Base.getindex(a::AbstractIndicesArray{T,N}, i...) where {T,N}
    _getindex(typeof(a), parent(a), axes(a), i)
end

#=

function Base.getindex(a::AbstractIndicesArray{T,N}, i, ii...) where {T,N}
   # @boundscheck checkbounds(a, i, ii...)
   # @inbounds

    _getindex(typeof(a), parent(a), axes(a), (i, ii...))
end

=#

function _getindex(
    ::Type{A},
    a::AbstractArray,
    axs::Tuple{Vararg{<:AbstractIndex}},
    i::Tuple{Vararg{Any}}
   ) where {A<:AbstractIndicesArray}

    maybe_indicesarray(A, a[map(to_index, axs, i)...], _drop_empty(map(getindex, axs, i)))
end

function maybe_indicesarray(
    ::Type{A},
    newarray::AbstractArray,
    axs::Tuple
   ) where {A<:AbstractIndicesArray}

    similar(A, newarray, axs)
end

maybe_indicesarray(::Type{A}, a::Any, axs::Tuple{}) where {A<:AbstractIndicesArray} = a


function _drop_empty(x::Tuple)
    if length(first(x)) > 1
        (first(x), _drop_empty(tail(x))...)
    else
        _drop_empty(tail(x))
    end
end

_drop_empty(x::Tuple{}) = ()

