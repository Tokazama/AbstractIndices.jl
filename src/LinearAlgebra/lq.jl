
LinearAlgebra.lq(a::IndicesArray, args...; kws...) = lq!(copy(a), args...; kws...)
function LinearAlgebra.lq!(a::IndicesArray, args...; kwargs...)
    inner = lq!(parent(nda), args...; kwargs...)
    return LQ(IndicesArray(getfield(inner, :factors), axes(a)), getfield(inner, :τ))
end
function Base.parent(fact::LQ{T,<:IndicesArray}) where {T}
    return LQ(parent(getfield(fact, :factors)), getfield(fact, :τ))
end

function Base.getproperty(fact::LQ{T,<:IndicesArray}, d::Symbol) where {T}
    if d === :L
        return IndicesArray{(n1, :_)}(getproperty(parent(fact), d), axes(fact, 1), nothing)
    elseif d === :Q
        return IndicesArray{(:_, n2)}(getproperty(parent(fact), d), nothing, axes(fact, 2))
    else
        return getproperty(parent(fact), d)
    end
end
