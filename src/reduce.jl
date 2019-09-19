function reducedim(a::AbstractIndex, dims, i::Int)
    if any(i .== dims)
        return SingleIndex(a)
    else
        return a
    end
end

function reduceaxes(a::AbstractIndicesArray{T,N}, dims) where {T,N}
    Tuple(map(i->reduced_dims(axes(a, i), dims, i), 1:N))
end


for (mod, funs) in ((:Base, (:sum, :prod, :maximum, :minimum, :extrema)),
                    (:Statistics, (:mean, :std, :var, :median)))
    for f in funs
        @eval function $mod.$f(a::AbstractIndicesArray; dims, kwargs...)
            similar(a, $mod.$f(parent(a); dims=dims, kwargs...), reduceaxes(a, dims))
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
