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
                    reduce_axes(a, d)
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

function Base.reduce(f, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(reduce(f, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

function Base.mapreduce(f, op, a::IndicesArray; dims=:, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(mapreduce(f, op, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

function Base.mapslices(f, a::IndicesArray; dims, kwargs...)
    d = to_dims(a, dims)
    return _maybe_indarray(mapslices(f, parent(a); dims=d, kwargs...), reduce_axes(a, d))
end

function Base.eachslice(a::IndicesArray; dims, kwargs...)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return _maybe_indarray(slice, reduce_axes(a, d))
    end
end

Base.selectdim(a::IndicesArray, d, i) = selectdim(a, to_dims(nda, d), i)
