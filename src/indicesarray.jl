"""
    IndicesArray
"""
struct IndicesArray{T,N,A<:Tuple{Vararg{<:Union{AbstractIndex,AbstractPosition},N}},D<:AbstractArray{T,N},F} <: AbstractIndicesArray{T,N,A,D,F}
    parent::D
    axes::A

end

IndicesArray(x::AbstractArray, axs::Vararg{Any}) = IndicesArray(x, Tuple(axs))

function IndicesArray(x::AbstractArray{T,N}; kwargs...) where {T,N}
    if isempty(kwargs)
        axs = axes(x)
    else
        axs = Tuple([NamedIndex{k}(v) for (k,v) in kwargs])
    end
    IndicesArray{T,N}(x, axs)
end

function IndicesArray(x::AbstractArray{T,N}, axs::Tuple{Vararg{<:Any,N}}) where {T,N}
    IndicesArray{T,N}(x,  axs)
end

function IndicesArray(x::AbstractArray{T,D}, names::NTuple{N,Symbol}) where {T,D,N}
    IndicesArray(x, Tuple(map(i->ifelse(i <= N, NamedIndex{names[i]}(axes(x, i)), axes(x, i)), 1:D)))
end

function IndicesArray{T,N}(x::AbstractArray{T,N}, axs::Tuple{Vararg{<:Any,N}}) where {T,N}
    newaxs = map(asindex, axs, axes(x))
    return IndicesArray{T,N,typeof(newaxs),typeof(x)}(x, newaxs)
end

function IndicesArray{T,N,A,D}(x::D, axs::A) where {T,N,A,D}
    f = false
    for i in axs
        if firstindex(i) != 1
            f = true
            break
        end
    end
    return IndicesArray{T,N,A,D,f}(x, axs)
end

const IndicesMatrix{T,Ax1,Ax2,D<:AbstractMatrix{T}} = IndicesArray{T,2,Tuple{Ax1,Ax2},D}

const IndicesVector{T,Ax,D<:AbstractVector{T}} = IndicesArray{T,1,Tuple{Ax},D}

const IndicesVecOrMat = Union{IndicesMatrix,IndicesVector}
#IndicesArray(x::AbstractArray{T,N}, axes::Tuple{Vararg{<:AbstractAxis,N}}) where {T,N} =
#    IndicesArray{T,N,typeof(x),typeof(axes)}(x, axes)

Base.parent(a::IndicesArray) = getproperty(a, :parent)

Base.axes(a::IndicesArray) = getproperty(a, :axes)

Base.isempty(a::IndicesArray) = isempty(parent(a))

function Base.similar(
    a::IndicesArray{T,N,A,D,F},
    eltype::Type=T,
    new_axes::Tuple{Vararg{Union{<:AbstractIndex,AbstractPosition}}}=axes(a)
   ) where {T,N,A,D,F}

    return IndicesArray(similar(parent(a), eltype, length.(new_axes)), new_axes)
end

function similar_type(
    ::IndicesArray{T,N,A,D},
    new_axes::Type=A,
    new_parent::Type=D
   ) where {T,N,A,D}
    return IndicesArray{eltype(new_parent),ndims(new_parent),new_axes,new_parent}
end
