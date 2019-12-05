"""
    reduce_indices(a; dims)

Returns the appropriate axes for a measure that reduces dimensions along the
dimensions `dims`.
"""
reduce_indices(a; dims) = reduce_indices(a, dims)
reduce_indices(a, dims) = _reduce_indices(axes(a), dims)
reduce_indices(a, dims::Colon) = ()
_reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduce_indices(axs, (dims,))
function _reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i -> ifelse(in(i, dims), reduce_index(axs[i]), axs[i]), 1:D))
end

"""
    reduce_index(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)

See also: [`reduce_indices`](@ref)
"""
reduce_index(a::AbstractIndex) = unsafe_reindex(a, 1:1)

_maybe_indarray(a, axs::Tuple) = IndicesArray(a, axs, AllUnique)
_maybe_indarray(a, axs::Tuple{}) = a

for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema, :all, :any, :findmax)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        f2 = Symbol(:_, f)
        @eval begin
            function $(mod).$(f)(a::IndicesArray; dims=:, kwargs...)
                d = to_dims(a, dims)
                return _maybe_indarray(
                    $(mod).$(f)(parent(a); dims=d, kwargs...),
                    reduce_indices(a, d)
                   )
            end
        end
    end
end

# `sort` and `sort!` don't change the index, just as it wouldn't on a normal vector
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumprod, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::IndicesArray; dims, kwargs...)
            return IndicesArray($mod.$fun(parent(a), dims=to_dims(a, dims), kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::IndicesVector; kwargs...)
            return IndicesArray($mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end


# reduce
function Base.reduce(f, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(reduce(f, parent(a); dims=d, kwargs...), reduce_indices(a, d))
end

# mapreduce
function Base.mapreduce(f, op, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(mapreduce(f, op, parent(a); dims=d, kwargs...), reduce_indices(a, d))
end

# mapslices
function Base.mapslices(f, a::IndicesArray; dims, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(mapslices(f, parent(a); dims=d, kwargs...), reduce_indices(a, d))
end

function Base.eachslice(a::IndicesArray; dims, kwargs...)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return _maybe_indarray(slice, reduce_indices(a, d))
    end
end

Base.selectdim(a::IndicesArray, d, i) = selectdim(a, to_dims(nda, d), i)
