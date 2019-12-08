
for f in (:mean, :std, :var, :median)
    f2 = Symbol(:_, f)
    @eval begin
        function Statistics.$(f)(a::IndicesArray; dims=:, kwargs...)
            d = to_dims(a, dims)
            return rebuild(
                a,
                Statistics.$(f)(parent(a); dims=d, kwargs...),
                reduce_axes(a, d)
               )
        end
    end
end

for f in (:cor, :cov)
    @eval begin
        function Statistics.$f(a::IndicesMatrix; dims=1, kwargs...)
            d = to_dims(a, dims)
            return rebuild(
                a,
                Statistics.$f(parent(a); dims=d, kwargs...),
                covcor_axes(a, d)
               )
        end

        Statistics.$f(a::IndicesVector) = Statistics.$f(parent(a))
    end
end

