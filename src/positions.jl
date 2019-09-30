"""
    AbstractPosition
"""
abstract type AbstractPosition{K,V,S} end

Base.length(::AbstractPosition) = 1

Base.firstindex(a::AbstractPosition) = keys(a)
Base.lastindex(a::AbstractPosition) = keys(a)

Base.first(a::AbstractPosition) = values(a)
Base.last(a::AbstractPosition) = values(a)

# TODO disable setproperty! so users cant make _state in outbounds
"""
    IndexPosition
The return from iterating over any `AbstractIndex` subtype. It ensures that
indexing back into the original structure doesn't degrade if indexing the
parent structure with a key or value would yield different results. Outside the
context of the parent 
"""
mutable struct IndexPosition{K,V,I<:AbstractIndex{K,V}} <: AbstractPosition{K,V,CartesianIndex{1}}
    _index::I
    _state::CartesianIndex{1}
end

IndexPosition(a::AbstractIndex{K,V}) where {K,V} = IndexPosition{K,V,typeof(a)}(a, CartesianIndex(1))

state(p::IndexPosition) = getfield(p, :_state)
Base.parent(p::IndexPosition) = getfield(p, :_index)
dimnames(p::IndexPosition) = dimnames(parent(p))
values(p::IndexPosition) = getindex(parent(p), state(p))
keys(p::IndexPosition) = getindex(keys(parent(p)), state(p))

@inline function unsafe_iterate!(p::IndexPosition)
    setfield!(p, :_state, getfield(p, :_state) + CartesianIndex(1))
end

function unsafe_values(p::IndexPosition)
    @inbounds getindex(parent(p), state(p))
end

