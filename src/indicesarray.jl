"""
    IndicesArray
"""
struct IndicesArray{T,N,A<:Tuple{Vararg{<:Union{AbstractIndex,AbstractPosition},N}},D<:AbstractArray{T,N},F} <: AbstractIndicesArray{T,N,A,D,F}
    parent::D
    axes::A

    function IndicesArray{T,N}(
        x::AbstractArray{T,N},
        axs::Tuple{Vararg{<:AbstractVector,N}}
       ) where {T,N}

        newaxs = Tuple(map(i -> asindex(axs[i], axes(x, i)), 1:N))
        f = false
        for i in newaxs
            if firstindex(i) != 1
                f = true
                break
            end
        end

        return new{T,N,typeof(newaxs),typeof(x),f}(x, newaxs)
    end

    function IndicesArray(x::AbstractArray{T,N}, axs::Tuple{Vararg{<:Union{Symbol,Nothing},N}}) where {T,N}
        newaxs = Tuple(map(i -> asindex(axes(x, i), getfield(axs, i)), 1:N))

        new{T,N,typeof(newaxs),typeof(x),false}(x, newaxs)
    end

    function IndicesArray{T,N,A,D}(x::D, axs::A) where {T,N,A,D}
        f = false
        for i in axs
            if firstindex(i) != 1
                f = true
                break
            end
        end

        return new{T,N,A,D,f}(x, axs)
    end
end

IndicesArray(x::AbstractArray, axs::Vararg{Union{Symbol,Nothing,<:AbstractVector}}) = IndicesArray(x, axs)

function IndicesArray(x::AbstractArray{T,N}; kwargs...) where {T,N}
    if isempty(kwargs)
        IndicesArray{T,N}(x, axes(x))
    else
        IndicesArray{T,N}(x, Tuple([asindex(v, k) for (k,v) in kwargs]))
    end
end
IndicesArray(x::AbstractArray{T,N}, axs::Tuple) where {T,N} = IndicesArray{T,N}(x,  axs)


const IndicesMatrix{T,Ax1,Ax2,D<:AbstractMatrix{T}} = IndicesArray{T,2,Tuple{Ax1,Ax2},D}

const IndicesVector{T,Ax,D<:AbstractVector{T}} = IndicesArray{T,1,Tuple{Ax},D}

const IndicesVecOrMat = Union{IndicesMatrix,IndicesVector}
#IndicesArray(x::AbstractArray{T,N}, axes::Tuple{Vararg{<:AbstractAxis,N}}) where {T,N} =
#    IndicesArray{T,N,typeof(x),typeof(axes)}(x, axes)

Base.parent(a::IndicesArray) = getproperty(a, :parent)

Base.axes(a::IndicesArray) = getproperty(a, :axes)

# TODO similar function and datatype
#function Base.similar(f::Union{Function,DataType}, shape::Tuple{AbstractIndex,Vararg{AbstractIndex}})
#    IndicesArray(f())
#    # body
#end
