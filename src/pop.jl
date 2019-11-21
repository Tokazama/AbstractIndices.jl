function Base.pop!(a::AbstractIndex)
    can_set_last(a) || error("Cannot change size of index of type $(typeof(a)).")
    pop!(keys(a))
    return pop!(values(a))
end

function Base.popfirst!(a::AbstractIndex)
    can_set_first(a) || error("Cannot change size of index of type $(typeof(a)).")
    popfirst!(keys(a))
    return popfirst!(values(a))
end

function Base.pop!(a::IndicesVector)
    pop!(axes(a, 1))
    return pop!(parent(a))
end

function Base.popfirst!(a::IndicesVector)
    popfirst!(axes(a, 1))
    return popfirst!(parent(a))
end

# TODO pop!(collection, key)
