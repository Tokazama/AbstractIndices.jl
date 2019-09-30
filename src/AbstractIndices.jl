module AbstractIndices

using LinearAlgebra, Statistics

import Base: length, axes, getindex, setindex, iterate, checkindex, checkbounds

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
       # methods
       asindex,
       dimnames,
       unname,
       filteraxes,
       namedaxes,
       unnamedaxes,
       findaxes,
       finddims,
       mapaxes,
       dropaxes,
       permuteaxes,
       reduceaxis,
       reduceaxes,
       hasdimnames

const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}

# AbstractIndex
include("traits.jl")
include("abstractindex.jl")

include("promote_shape.jl")
include("positions.jl")

include("findkeys.jl")
include("checkindex.jl")
include("to_index.jl")
include("to_indices.jl")
include("getindex.jl")
include("setindex.jl")
include("iterate.jl")

include("combine.jl")
include("union.jl")
include("vcat.jl")
include("merge.jl")


include("onetoindex.jl")
include("axisindex.jl")
include("namedindex.jl")
include("statickeys.jl")

include("abstractindicesarray.jl")
include("indicesarray.jl")


include("operators.jl")
include("similar.jl")
include("broadcasting.jl")
include("asindex.jl")

const TupleIndices{N} = Tuple{Vararg{<:AbstractIndex,N}}


include("indexing.jl")
include("math.jl")
include("reduce.jl")
include("subindices.jl")

include("show.jl")

end
