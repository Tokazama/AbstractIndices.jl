"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{K,V} <: AbstractVector{V} end

Base.valtype(::Type{<:AbstractIndex{K,V}}) where {K,V} = V

Base.keytype(::Type{<:AbstractIndex{K,V}}) where {K,V} = K

Base.length(a::AbstractIndex) = length(values(a))

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))


"""
    stepindex(x) -> Real

Returns the step size of the index.
"""
stepindex(a::AbstractIndex) = step(keys(a))

Base.lastindex(a::AbstractIndex) = last(keys(a))


Base.iterate(a::AbstractIndex) = iterate(values(a))

Base.iterate(a::AbstractIndex, state) = iterate(values(a), state)


# TODO rethink setaxis!
"""
    setaxis!(A::AxisIndex, val, i)

The equivalent of `setindex` for the axis values of `A`.
"""
function setaxis!(ai::AbstractIndex, val::Any, i::Any)
    @boundscheck checkbounds(keys(ai), i)
    @inbounds setindex!(keys(ai), val, to_index(keys(ai), i))
end


function Base.getindex(a::AbstractIndex, i::Any)
    @boundscheck if !checkindex(Bool, a, i)
        throw(BoundsError(a, i))
    end
    @inbounds to_index(a, i)
end

Base.getindex(a::AbstractIndex, i::Colon) = a

function getindex(A::AbstractArray{T,N}, i::Vararg{AbstractIndex,N}) where {T,N}
    getindex(A, to_indices(A, i))
end


Base.LinearIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = LinearIndices(values.(axs))

Base.CartesianIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N} = CartesianIndices(values.(axs))

Base.Slice(x::AbstractIndex) = Base.Slice(values(x))

"""
    SingleIndex

Represents a single point along an index. Useful for dimensions of length 1.
"""
struct SingleIndex{K,V} <: AbstractIndex{K,V}
    key::K
    val::V
end

Base.length(::SingleIndex) = 1

const TupleIndices{N} = Tuple{Vararg{<:AbstractIndex,N}}
