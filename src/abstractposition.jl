"""
    AbstractPosition
"""
abstract type AbstractPosition{K,V,S} end

Base.length(::AbstractPosition) = 1

Base.firstindex(a::AbstractPosition) = keys(a)
Base.lastindex(a::AbstractPosition) = keys(a)

Base.first(a::AbstractPosition) = values(a)
Base.last(a::AbstractPosition) = values(a)

keys(p::AbstractPosition) = keys(parent(p))[positionstate(p)]
values(p::AbstractPosition) = values(parent(p))[positionstate(p)]

isdone(p::AbstractPosition) = length(parent(p)) == positionstate(p)[1]

Base.iterate(p::AbstractPosition) = values(p), nothing

#=
function Base.iterate(a::AbstractIndex, state)
    newstate = nextind(a, state)
    return (a[newstate], newstate)
end
=#

function to_index(a::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V}
    if a == parent(i)
        return values(i)
    else
        # TODO don't know if this is the best outcome but should be rare
        return to_index(a, values(i))
    end
end

to_index(a::AbstractPosition) = values(a)

to_index(a::AbstractVector, i::AbstractPosition) = values(i)


# TODO isbefore
"""
    isbefore(a, b) -> Bool

Test if the index position `a` occurs before `b` n
"""
function isbefore end

# TODO isafter
"""
    isafter(a, b) -> Bool

Test if the index position `a` occurs after `b` n
"""
function isafter end



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

dimnames(p::AbstractPosition) = dimnames(p._index)
Base.parent(p::IndexPosition) = p._index
positionstate(p::IndexPosition) = p._state
reduceaxis(a::AbstractIndex) = IndexPosition(a)

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

