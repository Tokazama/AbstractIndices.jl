"""
    AbstractIndicesArray

"""
abstract type AbstractIndicesArray{T,N,A<:Tuple{Vararg{<:Union{AbstractIndex,AbstractPosition},N}},D<:AbstractArray{T,N},F} <: AbstractArray{T,N} end

const AbstractIndicesMatrix{T,A,D,F} = AbstractIndicesArray{T,2,A,D,F}

const AbstractIndicesVector{T,A,D,F} = AbstractIndicesArray{T,1,A,D,F}

const AbstractIndicesMatOrVec{T,A,D,F} = Union{AbstractIndicesMatrix{T,A,D,F},AbstractIndicesVector{T,A,D,F}}

const AbstractIndicesAdjoint{T,A,D<:AbstractVector{T},F} = AbstractIndicesMatrix{T,A,Adjoint{T,D},F}

const AbstractIndicesTranspose{T,A,D<:AbstractVector{T},F} = AbstractIndicesMatrix{T,A,Transpose{T,D},F}

dimnames(a::AbstractIndicesArray) = map(i -> dimnames(i), axes(a))
function unname(a::AbstractIndicesArray{T,N,A,D}) where {T,N,A,D}
    axs = unname.(axes(a))
    similar_type(a, typeof(axs), D)(parent(a), axs)
end


Base.IndexStyle(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = IndexStyle(D)

parenttype(::A) where {A<:AbstractIndicesArray} = parenttype(A)
parenttype(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = D

axestype(::A) where {A<:AbstractIndicesArray} = axestype(A)
axestype(::Type{<:AbstractIndicesArray{T,N,A,D}}) where {T,N,A,D} = A

Base.size(a::AbstractIndicesArray) = size(parent(a))
Base.size(a::AbstractIndicesArray, i::Any) = size(parent(a), finddims(a, i))

Base.isempty(a::AbstractIndicesArray) = isempty(parent(a))

Base.length(a::AbstractIndicesArray) = length(parent(a))

Base.has_offset_axes(::A) where {A<:AbstractIndicesArray} = has_offset_axes(A)
Base.has_offset_axes(::Type{<:AbstractIndicesArray{T,N,A,D,F}}) where {T,N,A,D,F} = F

function Base.dropdims(a::AbstractIndicesArray; dims)
    d = finddims(a, dims=dims)
    p = dropaxes(parent(a); dims=d)
    axs = dropaxes(a, dims=d)

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.permutedims(a::AbstractIndicesArray, perm)
    p = permutedims(parent(a), perm)
    axs = permuteaxes(a, perm)
    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

for f in (
    :(Base.transpose),
    :(Base.adjoint),
    :(Base.permutedims),
    :(LinearAlgebra.pinv))

    # Vector
    @eval function $f(a::AbstractIndicesVector)
        p = $f(parent(a))
        axs = (OneIndex(1), axes(a, 1))
        return similar_type(a, typeof(axs), typeof(p))(p, axs)
    end

    # Vector Double Transpose
    if f !== :permutedims
        @eval begin
            function $f(a::Union{AbstractIndicesAdjoint,AbstractIndicesTranspose})
                p = $f(parent(a))
                axs = (axes(a, 2),)
                return similar_type(a, typeof(axs), typeof(p))(p, axs)
            end
        end
    end

    # Matrix
    @eval function $f(a::AbstractIndicesMatrix)
        p = $f(parent(a))
        axs = (axes(a, 2), axes(a, 1))
        return similar_type(a, typeof(axs), typeof(p))(p, axs)
    end
end

for f in (:zero, :one, :copy)
    @eval function Base.$(f)(a::AbstractIndicesArray)
        similar_type(a)($(f)(parent(a)), axes(a))
    end
end

Base.:(==)(a::AbstractIndicesArray, b::AbstractIndicesArray) = parent(a) == parent(b)
Base.:(==)(a::AbstractArray, b::AbstractIndicesArray) = a == parent(b)
Base.:(==)(a::AbstractIndicesArray, b::AbstractArray) = parent(a) == b

Base.isequal(a::AbstractIndicesArray, b::AbstractIndicesArray) = isequal(parent(a), parent(b))
Base.isequal(a::AbstractArray, b::AbstractIndicesArray) = isequal(a, parent(b))
Base.isequal(a::AbstractIndicesArray, b::AbstractArray) = isequal(parent(a), b)

#= TODO
:sort,
:sort!
selectdim
copyto
reverse
iterate
promote_shape
reshape
=#
