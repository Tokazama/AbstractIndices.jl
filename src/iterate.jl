
Base.pairs(a::AbstractIndex) = Base.Iterators.Pairs(a, keys(a))

Base.eachindex(a::AbstractIndex) = keys(a)

Base.reverse(a::AbstractIndex) = asindex(reverse(keys(a)), IndexingStyle(a))

isdone(p::AbstractPosition) = length(parent(p)) == state(p)[1]

Base.iterate(p::AbstractPosition) = values(p), nothing

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
