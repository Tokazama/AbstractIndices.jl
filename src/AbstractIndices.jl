module AbstractIndices

using LinearAlgebra, Statistics, NamedDims

import Base: length, axes, getindex, checkindex, checkbounds
import Base: to_index, OneTo, tail, show, to_dim, values, keys

export AbstractIndex,
       AxisIndex,
       OneToIndex,
       StaticKeys,
       AbstractIndicesArray,
       IndicesArray,
       # methods
       stepindex,
       asindex,
       # NamedDims
       NamedDimsArray,
       # NamedDimsExtra
       filteraxes,
       findaxes,
       namedaxes



const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}

include("./NamedDimsExtra/NamedDimsExtra.jl")
using .NamedDimsExtra

include("utils.jl")
include("abstractindex.jl")
include("abstractindicesarray.jl")
include("to_index.jl")
include("checkindex.jl")
include("show.jl")
include("axisindex.jl")
include("onetoindex.jl")
include("statickeys.jl")
include("asindex.jl")
include("indicesarray.jl")
include("subindices.jl")

end
