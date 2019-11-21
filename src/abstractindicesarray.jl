"""
    AbstractIndicesArray

"""
abstract type AbstractIndicesArray{T,N,A<:Tuple{Vararg{<:Union{AbstractIndex,AbstractPosition},N}},D<:AbstractArray{T,N},F} <: AbstractArray{T,N} end

const AbstractIndicesMatrix{T,A,D,F} = AbstractIndicesArray{T,2,A,D,F}

const AbstractIndicesVector{T,A,D,F} = AbstractIndicesArray{T,1,A,D,F}

const AbstractIndicesMatOrVec{T,A,D,F} = Union{AbstractIndicesMatrix{T,A,D,F},AbstractIndicesVector{T,A,D,F}}

const AbstractIndicesAdjoint{T,A,D<:AbstractVector{T},F} = AbstractIndicesMatrix{T,A,Adjoint{T,D},F}

const AbstractIndicesTranspose{T,A,D<:AbstractVector{T},F} = AbstractIndicesMatrix{T,A,Transpose{T,D},F}

Base.IndexStyle(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = IndexStyle(D)

parenttype(::A) where {A<:AbstractIndicesArray} = parenttype(A)
parenttype(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = D

axestype(::A) where {A<:AbstractIndicesArray} = axestype(A)
axestype(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = A

Base.size(a::AbstractIndicesArray) = size(parent(a))
Base.size(a::AbstractIndicesArray, i::Any) = size(parent(a), to_dims(a, i))

Base.isempty(a::AbstractIndicesArray) = isempty(parent(a))

Base.length(a::AbstractIndicesArray) = length(parent(a))

indexnames(::A) where {A<:AbstractIndicesArray} = indexnames(A)
function indexnames(::Type{A})  where {A<:AbstractIndicesArray}
    map(indexnames, Tuple(axestype(A).parameters))
end

indexnames(::A, i::Int) where {A<:AbstractIndicesArray} = indexnames(A, i)
function indexnames(::Type{A}, i::Int)  where {A<:AbstractIndicesArray}
    indexnames(fieldtype(axestype(A), i))
end

function unname(a::AbstractIndicesArray{T,N,A,D}) where {T,N,A,D}
    axs = unname.(axes(a))
    similar_type(a, typeof(axs), D)(parent(a), axs)
end


Base.has_offset_axes(::A) where {A<:AbstractIndicesArray} = has_offset_axes(A)
Base.has_offset_axes(::Type{<:AbstractIndicesArray{T,N,A,D,F}}) where {T,N,A,D,F} = F

function maybe_indices_array(A::AbstractArray{T}, a::AbstractArray{T}, axs) where {T}
    similar_type(A, typeof(axs), typeof(a))(a, axs)
end
maybe_indices_array(A::AbstractArray{T}, a::T, axs) where {T} = a
maybe_indices_array(A::AbstractArray, a, axs) = a

# incase A is an array of arrays

#function maybe_indices_array(A::AbstractArray{T}, a::AbstractArray{T}, axs) where {T}
#    similar_type(A, typeof(axs), typeof(a))(a, axs)
#end
#maybe_indices_array(A::AbstractArray{T}, a::T, axs) where {T} = a
#maybe_indices_array(A::AbstractArray, a, axs) = a


for f in (:zero, :one, :copy)
    @eval function Base.$(f)(a::AbstractIndicesArray)
        similar_type(a)($(f)(parent(a)), axes(a))
    end
end

#= TODO
:sort,
:sort!
selectdim
copyto
reverse
iterate
=#
