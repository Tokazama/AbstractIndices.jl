
function Base.to_indices(A, inds::Tuple{<:AbstractIndex, Vararg{Any}}, I::Tuple{Any, Vararg{Any}})
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

function Base.to_indices(A, inds::Tuple{<:AbstractIndex, Vararg{Any}}, I::Tuple{Colon, Vararg{Any}})
    Base.@_inline_meta
    (values(first(inds)), to_indices(A, maybetail(inds), tail(I))...)
end

function Base.to_indices(A, inds::Tuple{<:AbstractIndex, Vararg{Any}}, I::Tuple{CartesianIndex{1}, Vararg{Any}})
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

maybetail(::Tuple{}) = ()
maybetail(t::Tuple) = tail(t)
