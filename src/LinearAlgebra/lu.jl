
function LinearAlgebra.lu!(a::IndicesArray, args...; kwargs...)
    inner_lu = lu!(parent(a), args...; kwargs...)
    return LU(
        IndicesArray(getfield(inner_lu, :factors), axes(a)),
        getfield(inner_lu, :ipiv),
        getfield(inner_lu, :info)
       )
end

function Base.parent(fact::LU{T,<:IndicesArray}) where {T}
    return LU(
        parent(getfield(fact, :factors)),
        getfield(fact, :ipiv),
        getfield(fact, :info)
       )
end

function Base.getproperty(fact::LU{T,<:IndicesArray{L}}, d::Symbol) where {T, L}
    return IndicesArray(
        getproperty(parent(fact), d),
        lu_indices(a, d),
        AllUnique,
        LengthChecked
       )
end

lu_indices(a::AbstractArray, d::Symbol) = lu_indices(axes(a), d)
function lu_indices(a::Tuple, d::Symbol)
    if d === :L
        return (unsafe_axes(a, 1), nothing)
    elseif d === :U
        return (nothing, unsafe_axes(a, 2))
    elseif d === :P
        return (unsafe_axes(a, 1), unsafe_axes(a, 1))
    elseif d === :p
        return (unsafe_axes(a, 1),)
    end
end
