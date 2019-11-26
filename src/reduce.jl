"""
    reduce_indices(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduce_indices(a::AbstractVector{T}) where {T} = one(T)

"""
    reduce_indices(a; dims)
"""
reduce_indices(a; dims) = reduce_indices(a, dims)
reduce_indices(a, dims) = _reduce_indices(axes(a), dims)
_reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduce_indices(axs, (dims,))
function _reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i->ifelse(in(i, dims), reduce_index(axs[i]), axs[i]), 1:D))
end

"""
    reduce_index(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduce_index(a::AbstractIndex) where {T} = unsafe_reindex(a, 1:1)



_maybe_array_reduce(a, axs::Tuple) = IndicesArray(a, axs, AllUnique)
_maybe_array_reduce(a, axs::Tuple{}) = a

for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema, :all, :any, :findmax)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        @eval begin
            function $(mod).$(f)(a::IndicesArray; dims=:, kwargs...)
                return _maybe_array_reduce(
                    $(mod).$(f)(a; dims=dims, kwargs...),
                    reduce_indices(axes(a), dims)
                )
            end
        end
    end
end

# reduce
function Base.reduce(f, a::IndicesArray; dims=:, kwargs...)
    return _maybe_array_reduce(
        reduce(f, parent(a); dims=dims, kwargs...),
        reduce_indices(axes(a), dims)
    )
end

# mapslices
function Base.mapslices(f, a::IndicesArray; dims=:, kwargs...)
    return _maybe_array_reduce(
        mapslices(f, parent(a); dims=dims, kwargs...),
        reduce_indices(axes(a), dims)
    )
end

# mapreduce
function Base.mapreduce(f, op, a::IndicesArray; dims=:, kwargs...)
    return _maybe_array_reduce(
        mapreduce(f, op, parent(a); kwargs...),
        reduce_indices(axes(a), dims)
    )
end
