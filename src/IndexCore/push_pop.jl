"""
    pop_index(x)

Returns the index `x` that corresponds to `pop`. New subtypes of `AbstractIndex`
must implement a unique `pop_index` method.
"""
pop_index(x::SimpleIndex{name}) where {name} = SimpleIndex{name}(pop(values(x)))
pop_index(x::Index{name}) where {name} = Index{name}(pop(keys(x)), pop(values(x)))

"""
    popfirst_index(x)

Returns the index `x` that corresponds to `pop`. New subtypes of `AbstractIndex`
must implement a unique `popfirst_index` method.
"""
popfirst_index(x::SimpleIndex) = pop_index(x)
popfirst_index(x::Index{name}) where {name} = Index{name}(popfirst(keys(x)), pop(values(x)))

"""
    pop_index!(x)

Returns the index `x` that corresponds to `pop!`.
"""
function pop_index!(x::SimpleIndex)
    pop!(values(x))
    return x
end
function pop_index!(x::AbstractIndex)
    pop!(keys(x))
    pop!(values(x))
    return x
end

"""
    popfirst_index!(x)

Returns the index `x` that corresponds to `popfirst!`.
"""
popfirst_index!(x::SimpleIndex) = pop_index!(x)
function popfirst_index!(x::Index)
    popfirst!(keys(x))
    pop!(values(x))
    return x
end

"""
    push_index!(x, items...)

Returns the index `x` appropriate for `push(vector, items...)`. If `items` are
`Pairs` then the first element of each pair is treated as a key to be appended to
those of of `x`.
"""
function push_index!(x::SimpleIndex, items...)
    set_length!(values(x), length(x) + length(items))
    return x
end
function push_index!(x::AbstractIndex, items...)
    len = length(x) + length(items)
    set_length!(keys(x), len)
    set_length!(values(x), len)
    return x
end
function push_index!(x::AbstractIndex, items::Pair...)
    len = length(x) + length(items)
    set_length!(values(x), len)
    ks = keys(x)
    f = unique_offset(ks)
    for i in items
        k, v = i
        if k in ks
            push!(ks, add_offset(ks, k, f))
        else
            push!(ks, k)
        end
    end
    return x
end

"""
    pushfirst_index!(x, items...)
"""
pushfirst_index!(x::SimpleIndex, items...) = push_index!(x, items...)
pushfirst_index!(x::AbstractIndex, items...) = push_index!(x, items...)
function pushfirst_index!(x::AbstractIndex, items::Pair...)
    len = length(x) + length(items)
    set_length!(values(x), len)
    ks = keys(x)
    f = unique_offset(ks)
    for i in items
        k, v = i
        if k in ks
            pushfirst!(ks, add_offset(ks, k, f))
        else
            pushfirst!(ks, k)
        end
    end
    return x
end
