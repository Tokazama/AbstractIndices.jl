module AbstractIndices

using LinearAlgebra, Statistics, Unitful, ArrayInterface, StaticRanges

using ArrayInterface: can_setindex

using Base: to_index, axes

import Base: getindex, setindex, iterate, checkindex, checkbounds

using Base.Broadcast:
    Broadcasted, BroadcastStyle, DefaultArrayStyle, AbstractArrayStyle, Unknown, combine_axes

using StaticRanges:
    can_set_length,
    can_set_first,
    can_set_last,
    ForwardOrdering,
    ReverseOrdering,
    ContinuousTrait,
    DiscreteTrait

import Base.Broadcast: combine_axes

# iterators
import Base: iterate, isdone, has_offset_axes
import Base.Iterators: Pairs

import Base: OneTo, tail, show, values, keys, @propagate_inbounds

export AbstractIndex,
       Index,
       IndicesArray,
       IndicesMatrix,
       IndicesVector

const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}

#=
include("promote_shape.jl")

include("checkindex.jl")

include("iterate.jl")

include("mutate.jl")

include("setindex.jl")

include("similar.jl")
include("broadcasting.jl")
=#

include("abstractindex.jl")
include("param_checks.jl")
include("index.jl")
include("indicesarray.jl")

include("to_index.jl")
include("to_indices.jl")
include("getindex.jl")


include("operators.jl")
include("matmul.jl")
include("push.jl")
include("pop.jl")
include("reduce.jl")
include("dimensions.jl")

#include("subindices.jl")

include("show.jl")

end
