Base.reverse(a::AbstractIndex) = asindex(reverse(keys(a)), reverse(values(a)))

Base.isdone(p::IndexPosition) = length(parent(p)) == state(p)[1]

Base.iterate(p::IndexPosition) = values(p), nothing

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

function Base.iterate(a::AbstractIndex{name1,K,V}, p::IndexPosition{name2,K,V}) where {name1,name2,K,V}
    if isdone(p)
        return nothing
    else
        p._state += CartesianIndex(1)
        return p, p
    end
end
