function IndicesDiagonal(v::AbstractVector)
    return IndicesArray(
        Diagonal(v),
        (axes(v, 1), axes(v, 1)),
        AllUnique,
        LengthChecked
       )
end

function LinearAlgebra.Diagonal(m::IndicesMatrix)
    return IndicesArray(
        diag(parent(m)),
        diagonal_indices(m),
        AllUnique,
        LengthChecked
       )
end

diagonal_indices(a::IndicesMatrix) = _diagonal_indices(a, findmin(size(a)))

function _diagional_indices(a::IndicesMatrix, imin::NTuple{2,Int})
    if last(imin) === 1
        return (axes(a, 1), unsafe_reindex(axes(a, 2), 1:first(imin)))
    else
        return (unsafe_reindex(axes(a, 1), 1:first(imin)), axes(a, 2))
    end
end

LinearAlgebra.diagm(v::IndicesVector) = IndicesArray(diagm(parent(v)), (axes(v, 1), axes(v, 1)))
