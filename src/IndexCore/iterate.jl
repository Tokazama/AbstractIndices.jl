
function iterate(a::AbstractIndex)
    if isempty(a)
        return nothing
    else
        return first(a), 1
    end
end

function Base.iterate(a::AbstractIndex, state::Int)
    if state < length(a)
        newstate = state + 1
        return @inbounds(values(a)[newstate]), newstate
    else
        return nothing
    end
end
