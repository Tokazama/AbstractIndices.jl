module AbstractIndices

using LinearAlgebra, Statistics, ArrayInterface, StaticRanges

using ArrayInterface: can_setindex

using Base: to_index, axes, broadcasted, AbstractCartesianIndex, @_propagate_inbounds_meta

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
    DiscreteTrait,
    similar_type,
    OneToRange,
    AbstractStepRange,
    AbstractStepRangeLen,
    AbstractLinRange,
    StaticUnitRange,
    Length,
    Size


import Base.Broadcast: combine_axes


# iterators
import Base: iterate, isdone, has_offset_axes
import Base.Iterators: Pairs

import Base: OneTo, tail, show, values, keys, @propagate_inbounds

export AbstractIndex,
       Index,
       SimpleIndex,
       IndicesArray,
       IndicesMatrix,
       IndicesVector,
       # methods
       filter_axes,
       dimnames,
       drop_axes,
       reindex,
       to_dims,
       # reexports
       mrange,
       srange,
       OneToSRange,
       OneToMRange,
       UnitMRange,
       UnitSRange,
       pop,
       popfirst



const TupOrVec{T} = Union{Tuple{Vararg{T}},AbstractVector{T}}

#=
include("promote_shape.jl")

include("checkindex.jl")

include("iterate.jl")

include("mutate.jl")

include("setindex.jl")
=#


include("IndexCore/IndexCore.jl")
include("IndicesArray/IndicesArray.jl")

include("similar.jl")

include("to_indices.jl")
include("getindex.jl")

include("operators.jl")
include("matmul.jl")
include("push_pop.jl")
include("reduce.jl")
include("permutedims.jl")
include("dropdims.jl")
include("math.jl")
include("broadcasting.jl")
include("show.jl")

include("LinearAlgebra/LinearAlgebra.jl")

end
