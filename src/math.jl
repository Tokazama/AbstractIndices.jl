# all AbstractIndicesArray
function Base.:*(a::AbstractIndicesVector, b::AbstractIndicesMatrix)
    p = *(parent(a), parent(b))
    axs = (axes(a, 1), axes(b, 2))

    return similar_type(b, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesMatrix)
    p = *(parent(a), parent(b))
    axs = (axes(a, 1), axes(b, 2))

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractIndicesMatrix, b::AbstractIndicesVector)
    p = *(parent(a), parent(b))
    axs = (axes(a, 1),)

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

# one is AbstractIndicesArray
function Base.:*(a::AbstractVector, b::AbstractIndicesMatrix)
    p = *(a, parent(b))
    axs = (axes(a, 1), axes(b, 2))
    return similar_type(b, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractIndicesVector, b::AbstractMatrix)
    p = *(parent(a), b)
    axs = (axes(a, 1), axes(b, 2))
 
    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractMatrix, b::AbstractIndicesMatrix)
    p = *(a, parent(b))
    axs = (axes(a, 1), axes(b, 2))
 
    return similar_type(b, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractIndicesMatrix, b::AbstractMatrix)
    p = *(parent(a), b)
    axs = (axes(a, 1), axes(b, 2))
 
    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractMatrix, b::AbstractIndicesVector)
    p = *(a, parent(b))
    axs = (axes(a, 1), axes(b, 2))
 
    return similar_type(b, typeof(axs), typeof(p))(p, axs)
end

function Base.:*(a::AbstractIndicesMatrix, b::AbstractVector)
    p = *(parent(a), b)
    axs = (axes(a, 1),)

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

function Base.inv(a::AbstractIndicesMatrix)
    p = inv(parent(a))
    axs = (axes(a,2), axes(a, 1))

    return similar_type(a, typeof(axs), typeof(p))(p, axs)
end

for f in (:cor, :cov)
    @eval begin 
        function Statistics.$f(a::AbstractIndicesMatrix; dims=1, kwargs...)
            p = Statistics.$f(parent(a); dims=dims, kwargs...)
            axs = symmetric_axes(axes(a), dims)

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
