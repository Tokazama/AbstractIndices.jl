
Base.iterate(a::AbstractIndex) = isempty(a) ? nothing : (first(a), 1)
function Base.iterate(a::AbstractIndex, state::Int)
    if state < length(a)
        newstate = state + 1
        return @inbounds(values(a)[newstate]), newstate
    else
        return nothing
    end
end

