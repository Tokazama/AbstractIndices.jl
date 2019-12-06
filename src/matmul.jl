for f in (:cor, :cov)
    @eval begin 
        function Statistics.$f(a::IndicesMatrix; dims=1, kwargs...)
            return _maybe_axes_array(
                Statistics.$f(parent(a); dims=dims, kwargs...),
                covcor_axes(a, dims)
               )
        end

        Statistics.$f(a::IndicesVector) = Statistics.$f(parent(a))
    end
end

for (A,B,fa,fb) in ((:AbstractMatrix, :IndicesMatrix,  identity, parent),
                    (:AbstractMatrix, :IndicesVector,  identity, parent),
                    (:IndicesMatrix,  :AbstractVector, parent,   parent),
                    (:IndicesMatrix,  :AbstractMatrix, parent,   identity),
                    (:IndicesVector,  :AbstractMatrix, parent,   identity),
                    (:AbstractVector, :IndicesMatrix,  identity, parent),
                    (:IndicesMatrix,  :IndicesVector,  parent,   parent),
                    (:IndicesMatrix,  :IndicesMatrix,  parent,   parent),
                    (:IndicesVector,  :IndicesMatrix,  parent,   parent))
    @eval begin
        function Base.:*(a::$A, b::$B)
            _maybe_axes_array(*($(fa)(a), $(fb)(b)), matmul_axes(a, b))
        end
    end
end

#Base.:*(a::IndicesVector, b::Adjoint{T,<:AbstractVector})

for A in (Adjoint{<:Any, <:AbstractVector}, Transpose{<:Real, <:AbstractVector{<:Real}})
    @eval begin
        Base.:*(a::$A, b::IndicesVector) where {T,I} = *(a, parent(b))
        Base.:*(b::IndicesVector, a::$A) where {T,I} = IndicesArray(*(parent(b), a), matmul_axes(b, a))
    end
end

Base.inv(a::IndicesMatrix) = IndicesArray(inv(parent(a)), inv_axes(a))
