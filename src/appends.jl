
function Base.append!(a::IndicesVector, b::AbstractVector)
    append_index!(a, b)
    append!(parent(a), b)
    return a
end

