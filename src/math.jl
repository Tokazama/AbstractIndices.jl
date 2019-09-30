# all AbstractIndicesArray

function _matmul(a::AbstractIndicesArray, p::AbstractArray, axs::Tuple)
    return similar_type(a,  typeof(axs), typeof(p))(p, axs)
end

function _matmul(a::AbstractIndicesArray, p::Real, axs::Tuple)
    return p
end

Base.:*(a::AbstractIndicesVector, b::AbstractIndicesMatrix) = _matmul(a, *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesMatrix) = _matmul(a, *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesVector) = _matmul(a, *(parent(a), parent(b)), (axes(a, 1),           ))
Base.:*(a::AbstractVector,        b::AbstractIndicesMatrix) = _matmul(b, *(       a , parent(b)), (axes(a, 1), axes(b, 2)))
Base.:*(a::AbstractIndicesVector, b::AbstractMatrix       ) = _matmul(a, *(parent(a),        b ), (axes(a, 1), axes(b, 2)))
Base.:*(a::AbstractMatrix,        b::AbstractIndicesMatrix) = _matmul(b, *(       a , parent(b)), (asindex(axes(a, 1)), axes(b, 2)))
Base.:*(a::AbstractIndicesMatrix, b::AbstractMatrix       ) = _matmul(a, *(parent(a),        b ), (axes(a, 1), asindex(axes(b, 2))))
Base.:*(a::AbstractMatrix,        b::AbstractIndicesVector) = _matmul(b, *(       a , parent(b)), (axes(a, 1),))

Base.:*(a::AbstractIndicesMatrix, b::AbstractVector) = _matmul(a, *(parent(a), b), (axes(a, 1),))

for A in (Adjoint{<:Any, <:AbstractVector}, Transpose{<:Real, <:AbstractVector{<:Real}})
    @eval function Base.:*(a::$A, b::AbstractIndicesArray{T,1,A,<:AbstractVector{T},F}) where {T,A,F}
        return *(a, parent(b))
    end
end

Base.inv(a::AbstractIndicesMatrix) = _matmul(a, inv(parent(a)), (axes(a,2), axes(a, 1)))

for f in (:cor, :cov)
    @eval begin 
        function Statistics.$f(a::AbstractIndicesMatrix; dims=1, kwargs...)
            d = finddims(a, dims)
            p = Statistics.$f(parent(a); dims=d, kwargs...)
            axs = symmetric_axes(axes(a), d)

            return similar_type(a, typeof(axs), typeof(p))(p, axs)
        end

        function Statistics.$f(a::AbstractIndicesVector)
            return Statistics.$f(parent(a))
        end
    end
end

function symmetric_axes(axs::Tuple{Vararg{Any,2}}, d::Int)
    if d == 1
        return (last(axs), last(axs))
    elseif d == 2
        return (first(axs), first(axs))
    end
end

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

