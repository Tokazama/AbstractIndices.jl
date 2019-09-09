"""
    AbstractIndicesArray

"""
abstract type AbstractIndicesArray{T,N,A,D} <: AbstractArray{T,N} end

const AbstractIndicesMatrix{T,A,D<:AbstractMatrix{T}} = AbstractIndicesArray{T,2,A,D}

const AbstractIndicesVector{T,A,D<:AbstractVector{T}} = AbstractIndicesArray{T,1,A,D}

const AbstractIndicesMatOrVec{T,A,D} = Union{AbstractIndicesMatrix{T,A,D},AbstractIndicesVector{T,A,D}}

"""
    axestypes(::AbstractIndicesArray)

Returns the the type of the axes
"""
axestypes(::A) where A<:AbstractIndicesArray = axestypes(A)

axestypes(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = A

Base.size(a::AbstractIndicesArray) = size(parent(a))
Base.size(a::AbstractIndicesArray, i::Any) = size(parent(a), i)

Base.isempty(a::AbstractIndicesArray) = isempty(parent(a))

Base.IndexStyle(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = IndexStyle(D)

Base.length(a::AbstractIndicesArray) = length(parent(a))

