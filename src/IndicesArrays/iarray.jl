"""
    IArray
"""
struct IArray{T,N,P<:AbstractArray{T,N},I<:NTuple{N,AbstractIndex}} <: IndicesArray{T,N,P,I}
    _parent::P
    _indices::I

    function IArray{T,N,P,I}(parent, indices, uc, lc) where {T,N,P,I}
        check_index_params(parent, indices, uc, lc)
        new{T,N,P,I}(parent, indices)
    end
end

function IArray(
    p::AbstractArray{T,N},
    inds::Tuple,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked,
   ) where {T,N}
    return IArray{T,N,typeof(p)}(
        p,
        map((a, i) -> _process_index(a, i, uc, lc), axes(p), inds),
        AllUnique,
        LengthChecked
       )
end

function IArray(p::AbstractArray{T,N}, axs::Tuple{Vararg{<:Union{Symbol,Nothing},N}}) where {T,N}
    return IArray{T,N,typeof(p)}(p, indices(p, axs), AllUnique, LengthChecked)
end

function IArray(
    p::AbstractVector,
    inds::AbstractVector,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked,
   )
    return IArray(p, (inds,), uc, lc)
end


function IArray{T,N,P}(
    p::P,
    inds::I,
    uc::Uniqueness,
    lc::AbstractLengthCheck
   ) where {T,N,P<:AbstractArray{T,N},I}
    return IArray{T,N,P,I}(p, inds, uc, lc)
end

#IArray(p::AbstractArray) = IArray(p, indices(p), AllUnique, LengthChecked)

function IArray(x::AbstractArray{T,N}; kwargs...) where {T,N}
    if isempty(kwargs)
        return IArray(x, indices(x), AllUnique, LengthChecked)
    else
        return IArray(x, Tuple([Index{k}(v) for (k,v) in kwargs]))
    end
end

function _process_index(a, i, uc, lc)
    check_index_length(a, i, lc)
    return Index(i, uc)
end

_process_index(a, ::Nothing, uc, lc) = Index(a, uc)
function _process_index(a, i::AbstractIndex, uc, lc)
    check_index_length(a, i, lc)
    return i
end

"""
    IMatrix{T,P,I1,I2}

Alias for two-dimensional `IArray`  with elements of type `T`, parent of
type `P`, and index of type `I1` and `I2`. Alias for [`IArray{T,1}`](@ref).
"""
const IMatrix{T,P<:AbstractMatrix{T},I1,I2} = IArray{T,2,P,Tuple{I1,I2}}

"""
    IVector{T,P,I}

Alias for one-dimensional `IArray`  with elements of type `T`, parent of
type `P`, and index of type `I`. Alias for [`IArray{T,1}`](@ref).
"""
const IVector{T,P<:AbstractVector{T},I1} = IArray{T,1,P,Tuple{I1}}

"""
    IVecOrMat{T}

Union type of [`IVector{T}`](@ref) and [`IMatrix{T}`](@ref).
"""
const IVecOrMat{T} = Union{IMatrix{T},IVector{T}}

const IAdjoint{T,P,I1,I2} = IMatrix{T,Adjoint{T,P},I1,I2}

const ITranspose{T,P,I1,I2} = IMatrix{T,Transpose{T,P},I1,I2}

const IDiagonal{T,V,I1,I2} = IMatrix{T,Diagonal{T,V},I1,I2}

const IQRCompactWY{T,P,I1,I2} = LinearAlgebra.QRCompactWY{T,IMatrix{T,P,I1,I2}}

const IQRPivoted{T,P,I1,I2} = QRPivoted{T,IMatrix{T,P,I1,I2}}

const IQR{T,P,I1,I2} = QR{T,IMatrix{T,P,I1,I2}}

const IQRUnion{T,P,I1,I2} = Union{IQRCompactWY{T,P,I1,I2},
                                  IQRPivoted{T,P,I1,I2},
                                  IQR{T,P,I1,I2}}

Base.parent(x::IArray) = getfield(x, :_parent)

Base.axes(x::IArray) = getfield(x, :_indices)
