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
    Continuous,
    DiscreteTrait,
    Discrete,
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
       IArray,
       IMatrix,
       IVector,
       # methods
       dimnames,
       unname,
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

include("IndexCore/IndexCore.jl")
using .IndexCore

include("IndicesArrays/IndicesArrays.jl")
include("LinearAlgebra/LinearAlgebra.jl")

end
