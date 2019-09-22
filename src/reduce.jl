
for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        @eval begin
            function $mod.$f(a::AbstractIndicesArray; dims=:, kwargs...)
                axs = reduceaxes(a, dims)
                if isempty(axs)
                    return $mod.$f(parent(a); dims=dims, kwargs...)
                else
                    p = $mod.$f(parent(a); dims=dims, kwargs...)
                    return similar_type(a, typeof(axs), typeof(p))(p, axs)
                end
            end
        end
    end
end

function Base.mapslices(a::AbstractIndicesArray; dims, kswargs...)
    p = mapslices(f, parent(a); dims=dims, kwargs...)
    axs = reduceaxes(a, dims)

    similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.mapreduce(a::AbstractIndicesArray; dims, kswargs...)
    p = mapreduce(f, parent(a); dims=dims, kwargs...)
    axs = reduceaxes(a, dims)

    similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.reduce(a::AbstractIndicesArray; dims, kswargs...)
    p = reduce(f, parent(a); dims=dims, kwargs...)
    axs = reduceaxes(a, dims)

    similar_type(a, typeof(axs), typeof(p))(p, axs)
end
