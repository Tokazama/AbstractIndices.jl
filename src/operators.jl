Base.:(==)(a::AbstractIndex, b::AbstractIndex) = values(a) == values(b)
Base.:(==)(a::AbstractIndex, b::AbstractVector) = values(a) == b
Base.:(==)(a::AbstractVector, b::AbstractIndex) = a == values(b)

# necessary to avoid ambiguity
Base.:(==)(a::AbstractIndex, b::AbstractUnitRange) = values(a) == b
Base.:(==)(a::AbstractUnitRange, b::AbstractIndex) = a == values(b)

function Base.:(==)(a::AbstractPosition, b::AbstractPosition)
    (parent(a) == parent(b)) & (state(a) == state(b))
end

Base.isequal(a::AbstractIndex,  b::AbstractIndex ) = isequal(values(a), values(b))
Base.isequal(a::AbstractIndex,  b::AbstractVector) = isequal(values(a),        b )
Base.isequal(a::AbstractVector, b::AbstractIndex ) = isequal(       a , values(b))

Base.allunique(a::AbstractIndex) = allunique(values(a))

Base.:(==)(a::AbstractIndicesArray, b::AbstractIndicesArray) = parent(a) == parent(b)
Base.:(==)(a::AbstractArray, b::AbstractIndicesArray) = a == parent(b)
Base.:(==)(a::AbstractIndicesArray, b::AbstractArray) = parent(a) == b

Base.isequal(a::AbstractIndicesArray, b::AbstractIndicesArray) = isequal(parent(a), parent(b))
Base.isequal(a::AbstractArray, b::AbstractIndicesArray) = isequal(a, parent(b))
Base.isequal(a::AbstractIndicesArray, b::AbstractArray) = isequal(parent(a), b)

