"""
    AbstractIndicesArray

"""
abstract type AbstractIndicesArray{T,N,A<:Tuple{Vararg{<:AbstractIndex,N}},D<:AbstractArray{T,N},F} <: AbstractArray{T,N} end

const AbstractIndicesMatrix{T,A,D} = AbstractIndicesArray{T,2,A,D}

const AbstractIndicesVector{T,A,D} = AbstractIndicesArray{T,1,A,D}

const AbstractIndicesMatOrVec{T,A,D} = Union{AbstractIndicesMatrix{T,A,D},AbstractIndicesVector{T,A,D}}

const AbstractIndicesAdjoint{T,A,D<:AbstractVector{T}} = AbstractIndicesMatrix{T,A,Adjoint{T,D}}

const AbstractIndicesTranspose{T,A,D<:AbstractVector{T}} = AbstractIndicesMatrix{T,A,Transpose{T,D}}

Base.size(a::AbstractIndicesArray) = size(parent(a))
Base.size(a::AbstractIndicesArray, i::Any) = size(parent(a), i)

Base.isempty(a::AbstractIndicesArray) = isempty(parent(a))

Base.length(a::AbstractIndicesArray) = length(parent(a))

Base.has_offset_axes(::A) where {A<:AbstractIndicesArray} = has_offset_axes(A)
Base.has_offset_axes(::Type{<:AbstractIndicesArray{T,N,A,D,F}}) where {T,N,A,D,F} = F

#= TODO think about what makes sense for setting in indices
function Base.setindex!(ai::AxisIndex, val::Any, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds setindex!(to_index(ai), val, to_index(ai, i))
end
=#
function Base.dropdims(a::AbstractIndicesArray; dims)
    p = dropaxes(parent(a); dims=dims)
    axs = dropaxes(a, dims=dims)

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.permutedims(a::AbstractIndicesArray, perm)
    p = permutedims(parent(a); dims=dims)
    axs = permuteaxes(a, dims)
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
        axs = (SingleIndex(a), axes(a, 1))
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
:sort, :sort!
mapslices
selectdim

broadcasting
copyto

reverse
iterate

promote_shape

reshape
=#
