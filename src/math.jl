# all AbstractIndicesArray
function Base.:*(a::AbstractIndicesVector, b::AbstractIndicesMatrix)
    similar(promote_type(typeof(a), typeof(b)), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end
function Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesMatrix)
    similar(promote_type(typeof(a), typeof(b)), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end
function Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesVector)
    similar(promote_type(typeof(a), typeof(b)), *(parent(a), parent(b)), (axes(a, 1),))
end

# one is AbstractIndicesArray
function Base.:*(a::AbstractVector, b::AbstractIndicesMatrix)
    similar(typeof(b), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end
function Base.:*(a::AbstractIndicesVector, b::AbstractMatrix)
    similar(typeof(a), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end

function Base.:*(a::AbstractMatrix, b::AbstractIndicesMatrix)
    similar(typeof(b), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end
function Base.:*(a::AbstractIndicesMatrix, b::AbstractMatrix)
    similar(typeof(a), *(parent(a), parent(b)), (axes(a, 1), axes(b, 2)))
end

function Base.:*(a::AbstractMatrix, b::AbstractIndicesVector)
    similar(typeof(b), *(parent(a), parent(b)), (axes(a, 1),))
end
function Base.:*(a::AbstractIndicesMatrix, b::AbstractVector)
    similar(typeof(a), *(parent(a), parent(b)), (axes(a, 1),))
end

function Base.inv(a::AbstractIndicesMatrix)
    similar(typeof(a), inv(parent(a)), (axes(a,2), axes(a, 1)))
end

for fun in (:cor, :cov)
    @eval function Statistics.$fun(a::AbstractIndicesMatrix; dims=1, kwargs...)
        return similar(a,
                       Statistics.$fun(parent(a); dims=dims, kwargs...),
                       symmetric_axes(axes(a), dims))
    end
end

function symmetric_axes(axs::Tuple{Vararg{Any,2}}, d::Int)
    if d == 1
        return (last(axs), last(axs))
    elseif d == 2
        return (first(axs), first(axs))
    end
end
Base.cumsum(a::AbstractIndicesArray; kwargs...) = similar(a, cumsum(parent(a), kwargs...), axes(a))

Base.cumprod(a::AbstractIndicesArray; kwargs...) = similar(a, cumsum(parent(a), kwargs...), axes(a))

# TODO do we need to specify cumsum! and cumprod!
