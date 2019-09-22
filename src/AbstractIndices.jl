module AbstractIndices

using LinearAlgebra, Statistics, NamedDims

import Base: length, axes, getindex, iterate, checkindex, checkbounds

# iterators
import Base: iterate, isdone, has_offset_axes
import Base.Iterators: Pairs

import Base: to_index, OneTo, tail, show, to_dim, values, keys
import NamedDims: unname

export AbstractIndex,
       IndexPosition,
       AxisIndex,
       OneToIndex,
       StaticKeys,
       NamedIndex,
       AbstractIndicesArray,
       IndicesArray,
       NamedAxes,
       # methods
       stepindex,
       asindex,
       # NamedDims
       NamedDimsArray,
       NamedIndicesArray,
       dimnames,
       # General - these combine the two
       filteraxes,
       findaxes,
       mapaxes



const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}


include("utils.jl")
include("abstractindex.jl")
include("abstractposition.jl")
include("abstractindicesarray.jl")


const NamedIndicesArray{L,T,N,Ax,D} = NamedDimsArray{L,T,N,<:AbstractIndicesArray{T,N,Ax,D}}
const NamedIndicesMatrix{L,T,Ax1,Ax2,D<:AbstractMatrix{T}} = NamedIndicesArray{L,T,2,Tuple{Ax1,Ax2},D}
const NamedIndicesVector{L,T,Ax1,D<:AbstractVector{T}} = NamedIndicesArray{L,T,1,Tuple{Ax1},D}

function NamedIndicesArray(a::AbstractArray, axs::Tuple)
    NamedDimsArray(IndicesArray(a, axs), dimnames(axs))
end

NamedIndicesArray(a::AbstractIndicesArray) = NamedDimsArray(a, dimnames(a))
NamedIndicesArray(a::AbstractArray; kwargs...) = NamedIndicesArray(a, NamedAxes(; kwargs...))

# FIXME: I had to define these functions to get test to pass but I assume that
# this should be possible to handle solely within NamedDims
Base.:(==)(a::NamedDimsArray, b::AbstractIndicesArray) = parent(a) == parent(b)
Base.:(==)(b::AbstractIndicesArray, a::NamedDimsArray) = parent(a) == parent(b)


Base.has_offset_axes(a::NamedIndicesArray) = has_offset_axes(parent(a))

Statistics.cov(a::NamedIndicesVector) = Statistics.cov(parent(parent(a)))

include("checkbounds.jl")
include("indexing.jl")
include("indicesarray.jl")
include("math.jl")
include("reduce.jl")
include("subindices.jl")
include("interface.jl")

include("show.jl")

end
