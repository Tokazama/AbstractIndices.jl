function LinearAlgebra.qr!(a::IndicesArray, args...; kwargs...)
    return _qr(qr!(parent(a), args...; kwargs...), axes(a))
end

function _qr(inner::QR, axs::Tuple)
    return QR(
        IndicesArray(inner.factors, axs, AllUnique, LengthChecked),
        inner.τ
       )
end

function Base.parent(fact::QR{<:Any, <:IndicesArray})
    return QR(parent(getfield(fact, :factors)), getfield(fact, :τ))
end

function _qr(inner::LinearAlgebra.QRCompactWY, inds::Tuple)
    return LinearAlgebra.QRCompactWY(
        IndicesArray(inner.factors, inds, AllUnique, LengthChecked),
        inner.T
       )
end
function Base.parent(fact::LinearAlgebra.QRCompactWY{<:Any, <:IndicesArray})
    return LinearAlgebra.QRCompactWY(
        parent(getfield(fact, :factors)),
        getfield(fact, :T)
       )
end

function _qr(inner::QRPivoted, axs::Tuple)
    return QRPivoted(
        IndicesArray(inner.factors, axs, AllUnique, LengthChecked),
        inner.τ,
        inner.jpvt
       )
end
function Base.parent(fact::QRPivoted{<:Any, <:IndicesArray})
    return QRPivoted(
        parent(getfield(fact, :factors)),
        getfield(fact, :τ),
        getfield(fact, :jpvt)
       )
end


function Base.getproperty(fact::IndicesQR, d::Symbol)
    inner = getproperty(parent(fact), d)
    axs = axes(fact)
    if d === :Q
        return IndicesArray(
            inner,
            (unsafe_axes(axs, 1), nothing),
            AllUnique,
            LengthChecked
           )
    elseif d === :R
        return IndicesArray(
            inner,
            (nothing, unsafe_axes(axs, 2)),
            AllUnique,
            LengthChecked
           )
    elseif fact isa QRPivoted && d === :P
        return IndicesArray(inner,
            (unsafe_axes(axs, 1), unsafe_axes(axs, 1)),
            AllUnique,
            LengthChecked
           )
    elseif fact isa QRPivoted && d === :p
        return IndicesArray(
            inner,
            (unsafe_axes(axs, 1),),
            AllUnique,
            LengthChecked
           )
    else
        return inner
    end
end
