Base.push!(a::IndicesVector, items...) = _push!(IndexTrait(a), a, items...)
function _push!(::ContinuousIndex, a, items...)
    set_length!(axes(a, 1), length(items) + length(a))
    push!(parent(a), items...)
    return a
end
function _push!(::DiscreteIndex, a, items::Pair...)
    push_keys!(axes(a, 1), first.(items)...)
    push!(parent(a), last.(items)...)
    return a
end

Base.pushfirst!(a::IndicesVector, items...) = _pushfirst!(IndexTrait(a), a, items...)
function _pushfirst!(::ContinuousIndex, a, items...)
    set_length!(axes(a, 1), length(items) + length(a))
    pushfirst!(parent(a), items...)
    return a
end
function _pushfirst!(::DiscreteIndex, a, items::Pair...)
    push_first_keys!(axes(a, 1), first.(items)...)
    pushfirst!(parent(a), last.(items)...)
    return a
end


function Base.pop!(a::IndicesVector)
    pop!(axes(1, 1))
    pop!(parent(a))
    return a
end

function Base.popfirst!(a::IndicesVector)
    popfirst!(axes(1, 1))
    popfirst!(parent(a))
    return a
end

# TODO pop!(collection, key)

function Base.append!(a::IndicesVector, b::AbstractVector)
    append_index!(a, b)
    append!(parent(a), b)
    return a
end

function Base.empty!(a::AbstractIndicesArray)
    empty!(axes(a, 1))
    empty!(parent(a))
    return a
end

# `sort` and `sort!` don't change the index, just as it wouldn't on a normal vector
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumprod, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::AbstractIndicesArray; dims, kwargs...)
            return IndicesArray($mod.$fun(parent(a), dims=dims, kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::AbstractIndicesVector; kwargs...)
            return IndicesArray($mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end
