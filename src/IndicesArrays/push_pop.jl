###
### push
###
function Base.push!(a::IndicesVector, items...)
    push_index!(a, items...)
    push!(parent(a), items...)
end
function Base.push!(x::IndicesVector, items::Pair...)
    push_index!(x, items...)
    for i in items
        k, v = i
        push!(parent(x), v)
    end
    return x
end

###
### push
###
function StaticRanges.push(x::IndicesVector, items...)
    return rebuild(x, push_index(x, items...), push(parent(x), items...))
end
function StaticRanges.push(x::IndicesVector, items::Pair...)
    p = parent(x)
    for i in items
        k, v = i
        p = push(parent(x), v)
    end
    return rebuild(x, p, push_index(x, items...))
end


###
### pushfirst!
###
function Base.pushfirst!(x::IndicesVector, items...)
    pushfirst_index!(x, items...)
    pushfirst!(parent(x), items...)
end
function Base.pushfirst!(x::IndicesVector, items::Pair...)
    pushfirst_index!(x, items...)
    for i in items
        k, v = i
        pushfirst!(parent(x), v)
    end
    return x
end

###
### pushfirst
###
function StaticRanges.pushfirst(x::IndicesVector, items...)
    return rebuild(x, pushfirst_index(x, items...), pushfirst(parent(x), items...))
end
function StaticRanges.pushfirst(x::IndicesVector, items::Pair...)
    p = parent(x)
    for i in items
        k, v = i
        p = pushfirst(parent(x), v)
    end
    return rebuild(x, p, pushfirst_index(x, items...))
end

###
### pop[!]
###
function Base.pop!(a::IndicesVector)
    pop_index!(axes(a, 1))
    return pop!(parent(a))
end

function StaticRanges.pop(a::IndicesVector)
    return rebuild(a, pop(parent(a)), (pop_index(axes(a, 1)),))
end

###
### popfirst[!]
###
function Base.popfirst!(a::IndicesVector)
    popfirst_index!(axes(a, 1))
    return popfirst!(parent(a))
end

function StaticRanges.popfirst(a::IndicesVector)
    return rebuild(a, popfirst(parent(a)), (popfirst_index(axes(a, 1)),))
end
