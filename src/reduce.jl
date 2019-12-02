#=
"""
    reduce_indices(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduce_indices(a::AbstractVector{T}) where {T} = one(T)
=#
"""
    reduce_indices(a; dims)
"""
reduce_indices(a; dims) = reduce_indices(a, dims)
reduce_indices(a, dims) = _reduce_indices(axes(a), dims)
_reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduce_indices(axs, (dims,))
function _reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i -> ifelse(in(i, dims), reduce_index(axs[i]), axs[i]), 1:D))
end

"""
    reduce_index(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduce_index(a::AbstractIndex) = unsafe_reindex(a, 1:1)

_maybe_array_reduce(a, axs::Tuple) = IndicesArray(a, axs, AllUnique)
_maybe_array_reduce(a, axs::Tuple{}) = a

for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema, :all, :any, :findmax)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        f2 = Symbol(:_, f)
        @eval begin
            $(mod).$(f)(a::IndicesArray; dims=:, kwargs...) = $(f2)(a, dims; kwargs...)

            function $(f2)(a, d; kwargs...)
                d2 = to_dims(a, d)
                return IndicesArray($(mod).$(f)(parent(a); dims=d2, kwargs...), reduce_indices(a, d2))
            end
            $(f2)(a, d::Colon; kwargs...) = $(mod).$(f)(parent(a); dims=d, kwargs...)
        end
    end
end

# `sort` and `sort!` don't change the index, just as it wouldn't on a normal vector
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumprod, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::IndicesArray; dims, kwargs...)
            return IndicesArray($mod.$fun(parent(a), dims=to_dim(a, dims), kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::IndicesVector; kwargs...)
            return IndicesArray($mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end


# reduce
Base.reduce(f, a::IndicesArray; dims=:, kwargs...) = _reduce(f, a, dims; kwargs...)
function _reduce(f, a, dims; kwargs...)
    d = to_dims(a, dims)
    return IndicesArray(reduce(f, parent(a); dims=d, kwargs...), reduce_indices(a, d))
end
_reduce(f, a, d::Colon; kwargs...) = reduce(f, parent(a); dims=d, kwargs...)

# mapreduce
function Base.mapreduce(f, op, a::IndicesArray; dims=:, kwargs...)
    return _mapreduce(f, op, a, dims; kwargs...)
end
function _mapreduce(f, op, a, dims; kwargs...)
    d = to_dims(a, dims)
    return IndicesArray(
        mapreduce(f, op, parent(a); dims=d, kwargs...),
        reduce_indices(a, d)
    )
end
_mapreduce(f, op, a, ::Colon; kwargs...) = mapreduce(f, op, parent(a); dims=:, kwargs...)

# mapslices
function Base.mapslices(f, a::IndicesArray; dims, kwargs...)
    d = to_dims(a, dims)
    return IndicesArray(
        mapslices(f, parent(a); dims=d, kwargs...),
        reduce_indices(a, d)
    )
end
