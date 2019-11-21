
Base.:(==)(a::IndicesArray, b::IndicesArray) = parent(a) == parent(b)
Base.:(==)(a::AbstractArray, b::IndicesArray) = a == parent(b)
Base.:(==)(a::IndicesArray, b::AbstractArray) = parent(a) == b

Base.isequal(a::IndicesArray, b::IndicesArray) = isequal(parent(a), parent(b))
Base.isequal(a::AbstractArray, b::IndicesArray) = isequal(a, parent(b))
Base.isequal(a::IndicesArray, b::AbstractArray) = isequal(parent(a), b)

