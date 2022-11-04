module AbstractIndices

using Base: @assume_effects

export NIndex, OpaqueIndex, MaskIndex

const ERROR_INDEX = 0
const BLANK_NAME = :_
const Eq{T} = Union{Base.Fix2{typeof(==),T},Base.Fix2{typeof(isequal),T}}

const IndexPrimitiveType = Union{Int,Bool,String,Symbol}
const IndexPrimitiveNames = (:Int,:Bool,:String,:Symbol)

include("NIndex.jl")
include("OpaqueIndex.jl")
include("MaskIndex.jl")
include("SubIndex.jl")
include("generate_tuple.jl")
include("generate_index.jl")

Base.IndexStyle(@nospecialize x::Union{Type{<:NIndex},Type{<:OpaqueIndex},NIndex,OpaqueIndex}) = IndexLinear()
Base.firstindex(@nospecialize x::Union{NIndex,OpaqueIndex}) = 1

_generate_index_methods(:NIndex)
_generate_index_methods(:OpaqueIndex)
for T in IndexPrimitiveNames
    _generate_private_tuple_methods(T)
    for itype in (:NIndex, :OpaqueIndex)
        _generate_index_type_methods(T, itype)
    end
end

function Base.showarg(io::IO, @nospecialize(x::NIndex), toplevel::Bool)
    toplevel || print(io, "::")
    print(io, "NIndex{", eltype(x), ", ", _length(x), "}")
end
function Base.showarg(io::IO, @nospecialize(x::OpaqueIndex), toplevel::Bool)
    toplevel || print(io, "::")
    print(io, "OpaqueIndex{", eltype(x), "}")
end
Base.show(io::IO, @nospecialize(x::Union{NIndex,OpaqueIndex})) = Base.show(io, MIME"text/plain"(), x)
function Base.show(io::IO, m::MIME"text/plain", @nospecialize(x::Union{NIndex,OpaqueIndex}))
    n = _length(x)
    print(io, n, "-element ")
    Base.showarg(io, x, true)
    if n === 0
        return nothing
    else
        print(io, ":\n")
        io = IOContext(io, :typeinfo => eltype(x))
        Base._print_matrix(io, Base.inferencebarrier(x), " ", "  ", "", "  \u2026  ", "\u22ee", "  \u22f1  ", 5, 5, 1:length(x), 1:1)
        nothing
    end
end

#=

using ArrayInterfaceCore
import ArrayInterfaceCore: ndims_index, ndims_shape, parent_type, buffer,
    known_first, known_last
using Base: @propagate_inbounds, to_index, Fix2

@static if isdefined(Base, Symbol("@assume_effects"))
    using Base: @assume_effects
else
    macro assume_effects(args...)
        if length(args) === 2 && first(args) === QuoteNode(:total)
            return :(Base.@pure $(ex))
        else
            return :($(args[end]))
        end
    end
end

include("KnownBuffer.jl")
include("scalar_index.jl")

const Collection{T} = Union{AbstractVector{T},Tuple{Vararg{T}}}
const ERROR_INDEX = typemin(Int)

@static if isdefined(ArrayInterfaceCore, :index_labels)
    index_labels1(x) = getfield(ArrayInterfaceCore.index_labels(x), 1)
else
    index_labels1(x) = Labels(UndefinedIndices(getfield(axes(x), 1)))
end
include("KnownBuffer.jl")

@nospecialize

#=
function show(io::IO, ::MIME"text/plain", u::UndefIndex)
    show(io, u)
    get(io, :compact, false)::Bool && return
    print(io, ": array initializer with undefined values")
end
=#

struct UndefinedIndices{I} <: AbstractVector{UndefIndex}
    indices::I

    UndefinedIndices(x::AbstractVector{Int}) = new{typeof(x)}(x)
end

Base.eltype(T::Union{Type{<:UndefinedIndices},UndefinedIndices}) = UndefIndex
Base.axes(x::UndefinedIndices) = axes(getfield(x, :indices))
Base.size(x::UndefinedIndices) = size(getfield(x, :indices))
Base.length(x::UndefinedIndices) = length(getfield(x, :indices))
function Base.getindex(x::UndefinedIndices, i::Integer)
    @boundscheck checkbounds(getfield(x, :indices), i)
    undefindex
end
function Base.getindex(x::UndefinedIndices, i::AbstractVector{<:Integer})
    @boundscheck checkbounds(getfield(x, :indices), i)
    UndefinedIndices(eachindex(i))
end
@propagate_inbounds function Base.getindex(x::UndefinedIndices, i::AbstractVector{Bool})
    x[Base.LogicalIndex(i)]
end

@specialize
include("utils.jl")
include("Values.jl")
include("show.jl")

is_applicable_index
search


#=
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
=#
=#

end
