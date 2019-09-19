module AbstractIndices

using LinearAlgebra, Statistics, NamedDims

import Base: length, axes, getindex, checkindex, checkbounds
import Base: to_index, OneTo, tail, show, to_dim, values, keys
import Base.Iterators: Pairs
import NamedDims: unname

export AbstractIndex,
       AxisIndex,
       OneToIndex,
       StaticKeys,
       NamedIndex,
       AbstractIndicesArray,
       IndicesArray,
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


# TODO remove this once implemented in NamedDims
dimnames(::NamedDimsArray{names}) where {names} = names
dimnames(::NamedDimsArray{names}, i) where {names} = names[i]
dimnames(::AbstractArray) = nothing

include("utils.jl")
include("abstractindex.jl")
include("abstractindicesarray.jl")
include("indexing.jl")
include("axes.jl")
include("indicesarray.jl")
include("math.jl")
include("reduce.jl")
include("subindices.jl")
include("interface.jl")

include("show.jl")

end



