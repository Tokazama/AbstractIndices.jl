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
