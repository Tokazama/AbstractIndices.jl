"""
    permute_indices(a, perms)

Returns indices of `a` in the order of `perms`.
"""
permute_indices(a, perms) = permute_indices(axes(a), perms)
function permute_indices(a::Tuple{Vararg{AbstractIndex,N}}, perms::NTuple{N,Any}) where {N}
    return permute_indices(a, to_dims(a, perms))
end
function permute_indices(a::Tuple{Vararg{AbstractIndex,N}}, perms::NTuple{N,Int}) where {N}
    return map(i -> getfield(a, i), perms)
end

Base.permutedims(a::IndicesArray, perms) = _permutedims(a, to_dims(a, perms))
function _permutedims(a, perms)
    IndicesArray(permutedims(parent(a), perms), permute_indices(a, perms), AllUnique, LengthChecked)
end

for f in (
    :(Base.transpose),
    :(Base.adjoint),
    :(Base.permutedims),
    :(LinearAlgebra.pinv))

    # Vector
    @eval function $f(a::IndicesVector)
        return IndicesArray($f(parent(a)), (axes(a, 1), axes(a, 1)), AllUnique, LengthChecked)
    end

    # Vector Double Transpose
    if f !== :(Base.permutedims)
        @eval begin
            function $f(a::Union{IndicesAdjoint,IndicesTranspose})
                return IndicesArray($f(parent(a)), (axes(a, 2),), AllUnique, LengthChecked)
            end
        end
    end

    # Matrix
    @eval function $f(a::IndicesMatrix)
        return IndicesArray($f(parent(a)), (axes(a, 2), axes(a, 1)), AllUnique, LengthChecked)
    end
end

