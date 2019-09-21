
abstract type AbstractPosition{K,V,S} end


length(::AbstractPosition) = 1

keys(p::AbstractPosition) = keys(parent(p))[positionstate(p)]
values(p::AbstractPosition) = values(parent(p))[positionstate(p)]

isdone(p::AbstractPosition) = length(parent(p)) == positionstate(p)[1]

#=
function Base.iterate(a::AbstractIndex, state)
    newstate = nextind(a, state)
    return (a[newstate], newstate)
end
=#


"""
    isbefore(a, b) -> Bool

Test if the index position `a` occurs before `b` n
"""
function isbefore end


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

function IndexPosition(a::AbstractIndex{K,V}) where {K,V}
    IndexPosition{K,V,typeof(a)}(a, CartesianIndex(1))
end

Base.parent(p::IndexPosition) = p._index
positionstate(p::IndexPosition) = p._state

function iterate(a::AbstractIndex)
    if isempty(a)
        return nothing
    else
        p = IndexPosition(a)
        return (p, p)
    end
end

function Base.iterate(a::AbstractIndex, state::Integer)
    if length(a) == state
        return nothing
    else
        p = IndexPosition(a, CartesianIndex(Int(state+1)))
        return p, p
    end
end


function Base.iterate(a::I, p::IndexPosition{K,V,I}) where {K,V,I<:AbstractIndex{K,V}}
    if isdone(p)
        return nothing
    else
        p._state += CartesianIndex(1)
        return p, p
    end
end

function Base.show(io::IO, p::IndexPosition{K,V,I}) where {K,V,I}
    print(io, "IndexPosition ($(positionstate(p)[1])):")
    print(io, " $(I.name)($(keys(p)) => $(values(p)))")
end

