
function LinearAlgebra.svd(a::IndicesArray{T}, args...; kwargs...) where {T}
    return svd!(
        LinearAlgebra.copy_oftype(a, LinearAlgebra.eigtype(T)),
        args...;
        kwargs...
    )
end

function LinearAlgebra.svd!(a::IndicesArray, args...; kwargs...)
    inner = svd!(parent(nda), args...; kwargs...)
    return SVD(
        IndicesArray(getfield(inner, :U), axes(a)),
        getfield(inner, :S),
        IndicesArray(getfield(inner, :Vt), axes(a))
       )
end

function Base.parent(fact::SVD{T,Tr,<:IndicesArray}) where {T,Tr}
    return SVD(parent(getfield(fact, :U)), getfield(fact, :S), parent(getfield(fact, :Vt)))
end

function Base.getproperty(fact::SVD{T,Tr,<:IndicesArray}, d::Symbol) where {T,Tr}
    inner = getproperty(parent(fact), d)
    axs = axes(fact)
    if d === :U
        return IndicesArray(inner, (unsafe_axes(a, 1), nothing), AllUnique, LengthChecked)
    elseif d === :V
        return IndicesArray(inner, (nothing, unsafe_axes(a, 2)), AllUnique, LengthChecked)
    elseif d === :Vt
        return IndicesArray(inner, (unsafe_axes(a, 2), nothing), AllUnique, LengthChecked)
    else # d === :S
        return inner
    end
end
