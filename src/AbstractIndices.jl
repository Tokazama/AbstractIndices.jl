module AbstractIndices

using LinearAlgebra, Statistics

import Base: length, axes, getindex, iterate, checkindex, checkbounds

using Base.Broadcast:
    Broadcasted, BroadcastStyle, DefaultArrayStyle, AbstractArrayStyle, Unknown, combine_axes

import Base.Broadcast: combine_axes

# iterators
import Base: iterate, isdone, has_offset_axes
import Base.Iterators: Pairs

import Base: to_index, OneTo, tail, show, to_dim, values, keys

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
       asindex,
       dimnames,
       unname,
       filteraxes,
       findaxes,
       finddims,
       mapaxes,
       dropaxes,
       permuteaxes,
       reduceaxis,
       reduceaxes

const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}

include("utils.jl")
include("indexingstyle.jl")
include("interface.jl")
include("abstractindex.jl")
include("onetoindex.jl")
include("axisindex.jl")
include("statickeys.jl")
include("namedindex.jl")
include("asindex.jl")
include("abstractposition.jl")
include("abstractindicesarray.jl")
include("indicesarray.jl")

include("checkbounds.jl")
include("combine.jl")
include("indexing.jl")
include("math.jl")
include("reduce.jl")
include("broadcasting.jl")
include("subindices.jl")

include("show.jl")

end
