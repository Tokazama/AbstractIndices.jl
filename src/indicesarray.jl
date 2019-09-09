
# TODO fix terrible error message
checkparams(p::Tuple, a::Tuple) = map(checkparams_each, p, a)

function checkparams_each(p_i, a_i)
    all(axes(p_i, 1) .== to_index(a_i)) || error("Not all indices for parent araay are appropriately indexed by axes")
end

"""
    IndicesArray
"""
struct IndicesArray{T,N,A<:Tuple{Vararg{<:AbstractIndex,N}},D<:AbstractArray{T,N}} <: AbstractIndicesArray{T,N,A,D}
    parent::D
    axes::A

    function IndicesArray{T,N,A,D}(p::D, a::A) where {T,N,A,D}
        checkparams(axes(p), a)
        new{T,N,A,D}(p::D, a::A)
    end
end

function IndicesArray(x::AbstractArray{T,N}, axs::Tuple{Vararg{<:AbstractIndex,N}}) where {T,N}
    IndicesArray{T,N,typeof(axs),typeof(x)}(x, axs)
end

IndicesArray(x::AbstractArray, axs::Vararg) = IndicesArray(x, Tuple(axs))


IndicesArray(x::AbstractArray, axs::Tuple) = IndicesArray(x, map(asindex, axs, axes(x)))

IndicesArray(x::AbstractArray) = IndicesArray(x,  axes(x))

const IndicesMatrix{T,Ax1,Ax2,D<:AbstractMatrix{T}} = IndicesArray{T,2,Tuple{Ax1,Ax2},D}

const IndicesVector{T,Ax,D<:AbstractVector{T}} = IndicesArray{T,1,Tuple{Ax},D}

const IndicesVecOrMat = Union{IndicesMatrix,IndicesVector}
#IndicesArray(x::AbstractArray{T,N}, axes::Tuple{Vararg{<:AbstractAxis,N}}) where {T,N} =
#    IndicesArray{T,N,typeof(x),typeof(axes)}(x, axes)

Base.parent(a::IndicesArray) = getproperty(a, :parent)

Base.axes(a::IndicesArray) = getproperty(a, :axes)

Base.isempty(a::IndicesArray) = isempty(parent(a))
