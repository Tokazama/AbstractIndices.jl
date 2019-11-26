# TODO
# push_first_keys!
# push_first_keys
# push_keys!
# push_keys

push_key!(a::AbstractIndex, k) = _push_key!(order(keys(a)), a, k)

function _push_key!(::ForwardOrdering, a, k)
    k > lastindex(a) || error("$k must be ")
end
function StaticRanges.push(a::IndicesVector{T,P,I1}, items...) where {T,P,I1}
    return _pushfirst(Continuity(keys_type(I1)), a, items...)
end

function _push(::ContinuousTrait, a, items...)
    return IndicesArray(
        push(parent(a), last.(items)...),
        (set_length(axes(a, 1), length(items) + length(a)),),
        AllUnique,
        LengthChecked
       )
end
function _push(::DiscreteTrait, a, items::Pair...)
    return IndicesArray(
        push(parent(a), last.(items)...),
        (push_keys(axes(a, 1), first.(items)...),),
        AllUnique,
        LengthChecked
       )
end

###
### push
###
Base.push!(a::IndicesVector, items...) = _push!(IndexTrait(), a, items...)
function _push!(::ContinuousTrait, a, items...)
    set_length!(axes(a, 1), length(items) + length(a))
    push!(parent(a), items...)
    return a
end

function _push!(::DiscreteTrait, a, items::Pair...)
    push_keys!(axes(a, 1), first.(items)...)
    push!(parent(a), last.(items)...)
    return a
end

###
### pushfirst
###
function Base.pushfirst!(a::IndicesVector{T,P,I1}, items...) where {T,P,I1}
    return _pushfirst!(Continuity(keys_type(I1)), a, items...)
end
function _pushfirst!(::ContinuousTrait, a, items...)
    set_length!(axes(a, 1), length(items) + length(a))
    pushfirst!(parent(a), items...)
    return a
end
function _pushfirst!(::DiscreteTrait, a, items::Pair...)
    push_first_keys!(axes(a, 1), first.(items)...)
    pushfirst!(parent(a), last.(items)...)
    return a
end

function StaticRanges.pushfirst(a::IndicesVector{T,P,I1}, items...) where {T,P,I1}
    return _pushfirst(Continuity(keys_type(I1)), a, items...)
end

function _pushfirst(::ContinuousTrait, a, items...)
    return IndicesArray(
        pushfirst(parent(a), last.(items)...),
        (set_length(axes(a, 1), length(items) + length(a)),),
        AllUnique,
        LengthChecked
       )
end

function _pushfirst(::DiscreteTrait, a, items::Pair...)
    return IndicesArray(
        push(parent(a), last.(items)...),
        (push_first_keys(axes(a, 1), first.(items)...),),
        AllUnique,
        LengthChecked
       )
end
