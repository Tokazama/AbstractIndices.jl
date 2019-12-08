for f in (:sum, :prod, :maximum, :minimum, :extrema, :all, :any, :findmax)
    @eval begin
        function Base.$(f)(a::IndicesArray; dims=:, kwargs...)
            d = to_dims(a, dims)
            return rebuild(
                a,
                Base.$(f)(parent(a); dims=d, kwargs...),
                reduce_axes(a, d)
               )
        end
    end
end

for f in (:cumsum, :cumprod, :sort, :sort!)
    @eval begin
        function Base.$(f)(a::IndicesArray; dims, kwargs...)
            return rebuild(a, $(f)(parent(a), dims=to_dims(a, dims), kwargs...), axes(a))
        end

        function Base.$(f)(a::IndicesVector; kwargs...)
            return rebuild(a, $(f)(parent(a); kwargs...), axes(a))
        end
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
            rebuild(rebuild_rule(a, b), *($(fa)(a), $(fb)(b)), matmul_axes(a, b))
        end
    end
end

for A in (Adjoint{<:Any, <:AbstractVector}, Transpose{<:Real, <:AbstractVector{<:Real}})
    @eval begin
        Base.:*(a::$A, b::IndicesVector) where {T,I} = *(a, parent(b))
        function Base.:*(b::IndicesVector, a::$A) where {T,I}
            return rebuild(b, *(parent(b), a), matmul_axes(b, a))
        end
    end
end

# Between arrays
function Base.:+(a::IndicesArray, b::IndicesArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        +(parent(a), parent(b)),
        combine_axes(a, b)
       )
end
function Base.:+(a::AbstractArray, b::IndicesArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        +(a, parent(b)),
        combine_axes(a, b)
       )
end
function Base.:+(a::IndicesArray, b::AbstractArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        +(parent(a), b),
        combine_axes(a, b)
       )
end

function Base.:-(a::IndicesArray, b::IndicesArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        -(parent(a), parent(b)),
        combine_axes(a, b)
       )
end
function Base.:-(a::AbstractArray, b::IndicesArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        -(a, parent(b)),
        combine_axes(a, b)
       )
end
function Base.:-(a::IndicesArray, b::AbstractArray)
    return rebuild(
        promote_rule(typeof(a), typeof(b)),
        -(parent(a), b),
        combine_axes(a, b)
       )
end
function Base.:-(a::IndicesArray, b::IndicesArray, c...)
    return -(rebuild(a, -(parent(a), parent(b)), combine_indices(a, b)), c...)
end
function Base.:-(a::AbstractArray, b::IndicesArray, c...)
    return -(rebuild(a, -(a, parent(b)), axes(b)), c...)
end
function Base.:-(a::IndicesArray, b::AbstractArray, c...)
    return -(rebuild(a, -(parent(a), b), axes(a)), c...)
end

Base.:*(a::Number, b::IndicesArray) = rebuild(b, *(a, parent(b)), axes(b))
Base.:*(a::IndicesArray, b::Number) = rebuild(a, *(parent(a), b), axes(a))

Base.:\(a::Number, b::IndicesArray) = rebuild(b, \(a, parent(b)), axes(b))
Base.:/(a::IndicesArray, b::Number) = rebuild(a, /(parent(a), b), axes(a))

