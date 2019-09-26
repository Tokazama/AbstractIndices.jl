

for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema, :all, :any, :findmax)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        subf = Symbol(:_, f)
        @eval begin
            function $mod.$f(a::AbstractIndicesArray; dims=:, kwargs...)
                $subf(a, dims; kwargs...)
            end

            function $subf(a::AbstractIndicesArray, dims::Colon; kwargs...)
                return $mod.$f(parent(a); dims=:, kwargs...)
            end

            function $subf(a::AbstractIndicesArray, dims::Any; kwargs...)
                d = finddims(a, dims=dims)
                return maybe_indicesarray(a, $mod.$f(parent(a); dims=d, kwargs...), reduceaxes(a, d))
            end

        end
    end
end

function Base.mapslices(f, a::AbstractIndicesArray; dims=:, kwargs...)
    _mapslices(f, a, dims; kwargs...)
end

function _mapslices(f, a::AbstractIndicesArray, dims::Colon; kwargs...)
    return mapslices(f, parent(a); dims=d, kwargs...)
end

function _mapslices(f, a::AbstractIndicesArray, dims::Any; kwargs...)
    d = finddims(a, dims=dims)
    return maybe_indicesarray(a, mapslices(f, parent(a); dims=d, kwargs...), reduceaxes(a, dims=d))
end

function Base.mapreduce(f, op, a::AbstractIndicesArray; dims=:, kwargs...)
    _mapreduce(f, op, a, dims; kwargs...)
end

function _mapreduce(f, op, a::AbstractIndicesArray, dims::Colon; kwargs...)
    return mapreduce(f, op, parent(a); kwargs...)
end

function _mapreduce(f, op, a::AbstractIndicesArray, dims::Any; kwargs...)
    d = finddims(a, dims=dims)
    return maybe_indicesarray(a, mapreduce(f, op, parent(a); dims=d, kwargs...), reduceaxes(a, dims=d))
end

function Base.reduce(a::AbstractIndicesArray; dims=:, kwargs...)
    d = finddims(a, dims=dims)
    maybe_indicesarray(a, reduce(f, parent(a); dims=d, kwargs...), reduceaxes(a, dims=d))
end

# FIXME Should sort and sort! effect the index labels?
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumsum!, :cumprod, :cumprod!, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::AbstractIndicesArray; dims, kwargs...)
            return maybe_indicesarray(a, $mod.$fun(parent(a); dims=finddims(a, dims), kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::AbstractIndicesVector; kwargs...)
            return maybe_indicesarray(a, $mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end

function Base.eachslice(a::AbstractIndicesArray; dims, kwargs...)
    d = finddims(a, dims)
    slices = eachslice(parent(a); dims=d, kwargs...)
    return Base.Generator(slices) do slice
        return maybe_indicesarray(slice, reduceaxes(a, d))
    end
end
