function reducedim(a::AbstractIndex, dims, i::Int)
    if any(i .== dims)
        return SingleIndex(a)
    else
        return a
    end
end


reduceaxes(a::AbstractIndicesArray{T,N}, dims::Colon) where {T,N} = ()
function reduceaxes(a::AbstractIndicesArray{T,N}, dims) where {T,N}
    Tuple(map(i->reducedim(axes(a, i), dims, i), 1:N))
end


for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        @eval begin
            function $mod.$f(a::AbstractIndicesArray; dims=:, kwargs...)
                axs = reduceaxes(a, dims)
                if isempty(axs)
                    return $mod.$f(parent(a); dims=dims, kwargs...)
                else
                    similar(a, $mod.$f(parent(a); dims=dims, kwargs...), axs)
                end
            end
        end
    end
end

function Base.mapslices(a::AbstractIndicesArray; dims, kswargs...)
    similar(a, mapslices(f, parent(a); dims=dims, kwargs...), reduceaxes(a, dims))
end

function Base.mapreduce(a::AbstractIndicesArray; dims, kswargs...)
    similar(a, mapreduce(f, parent(a); dims=dims, kwargs...), reduceaxes(a, dims))
end

function Base.reduce(a::AbstractIndicesArray; dims, kswargs...)
    similar(a, reduce(f, parent(a); dims=dims, kwargs...), reduceaxes(a, dims))
end
