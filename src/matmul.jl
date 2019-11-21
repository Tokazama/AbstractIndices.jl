matmul_indices(a::AbstractArray,  b::AbstractArray ) = matmul_indices(indices(a), indices(b))
matmul_indices(a::Tuple{Any},     b::Tuple{Any,Any}) = (first(a), last(b))
matmul_indices(a::Tuple{Any,Any}, b::Tuple{Any,Any}) = (first(a), last(b))
matmul_indices(a::Tuple{Any,Any}, b::Tuple{Any}    ) = (first(a),)
matmul_indices(a::Tuple{Any},     b::Tuple{Any}    ) = ()

@inline function covcor_indices(a, dims::Int)
    if d === 1
        return (axes(a, 2), axes(a, 2))
    elseif d === 2
        return (axes(a, 1), axes(a, 1))
    else
        error("dims must be 1 or 2.")
    end
end

inv_indices(a) = (axes(a, 2), axes(a, 1))


for f in (:cor, :cov)
    @eval begin 
        function Statistics.$f(a::IndicesMatrix; dims=1, kwargs...)
            d = to_dims(a, dims)
            return _maybe_indices_array_getindex(
                Statistics.$f(parent(a); dims=d, kwargs...),
                covcor_axes(a, d)
               )
        end

        Statistics.$f(a::IndicesVector) = Statistics.$f(parent(a))
    end
end

for (A,B,fa,fb) in ((:AbstractMatrix, :IndicesMatrix, identity, parent),
                    (:AbstractMatrix, :IndicesVector, identity, parent),
                    (:IndicesMatrix,  :AbstractVector, parent, parent),
                    (:IndicesMatrix,  :AbstractMatrix, parent, identity),
                    (:IndicesVector,  :AbstractMatrix, parent, identity),
                    (:AbstractVector, :IndicesMatrix, identity, parent),
                    (:IndicesMatrix,  :IndicesVector, parent, parent),
                    (:IndicesMatrix,  :IndicesMatrix, parent, parent),
                    (:IndicesVector,  :IndicesMatrix, parent, parent))
    @eval begin
        function Base.:*(a::$A, b::$B)
            _maybe_indices_array(*($(fa)(a), $(fb)(b)), matmul_indices(a, b))
        end
    end
end

Base.inv(a::IndicesMatrix) = IndicesArray(inv(parent(a)), inv_indices(a))
#Base.:*(a::IndicesVector, b::Adjoint{T,<:AbstractVector})

for A in (Adjoint{<:Any, <:AbstractVector}, Transpose{<:Real, <:AbstractVector{<:Real}})
    @eval begin
        Base.:*(a::$A, b::IndicesVector) where {T,I} = *(a, parent(b))
        Base.:*(b::IndicesVector, a::$A) where {T,I} = IndicesArray(*(parent(b), a), matmul_indices(b, a))
    end
end
