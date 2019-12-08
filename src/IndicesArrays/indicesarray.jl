abstract type IndicesArray{T,N,P,I} <: AbstractArray{T,N} end

###
### Interface
###
parent_type(::T) where {T<:AbstractArray} = axes_type(T)
parent_type(::Type{<:IndicesArray{T,N,P,I}}) where {T,N,P,I} = P

axes_type(::T) where {T<:AbstractArray} = axes_type(T)
axes_type(::Type{<:IndicesArray{T,N,P,I}}) where {T,N,P,I} = I

Base.parentindices(x::IndicesArray) = axes(parent(x))

Base.length(a::IndicesArray) = axes2length(axes(a))

Base.size(a::IndicesArray) = axes2size(axes(a))

@propagate_inbounds Base.size(a::IndicesArray, i) = length(axes(a, i))

Base.axes(a::IndicesArray, i) = unsafe_axes(axes(a), to_dims(a, i))
unsafe_axes(axs::Tuple, idx::Int) = axs[idx]

"""
    indices(x) -> Tuple
"""
indices(x::IndicesArray) = axes(x)

function indices(x::AbstractArray)
    if is_static(x)
        return map(i -> SimpleIndex(OneToSRange(i)), size(x))
    elseif is_fixed(x)
        return map(i -> SimpleIndex(OneTo(i)), size(x))
    else
        return map(i -> SimpleIndex(OneToMRange(i)), size(x))
    end
end

function indices(x::AbstractArray{T,N}, dimnames::Tuple{Vararg{Union{Symbol,Nothing},N}}) where {T,N}
    if is_static(x)
        return map((d, s) -> SimpleIndex{d}(OneToSRange(s)), dimnames, size(x))
    elseif is_fixed(x)
        return map((d, s) -> SimpleIndex{d}(OneTo(s)), dimnames, size(x))
    else
        return map((d, s) -> SimpleIndex{d}(OneToMRange(s)), dimnames, size(x))
    end
end


"""
    IndicesMatrix{T,I1,I2}

Alias for two-dimensional `IndicesArray`  with elements of type `T`, parent of
type `P`, and index of type `I1` and `I2`. Alias for [`IndicesArray{T,1}`](@ref).
"""
const IndicesMatrix{T,P,I1,I2} = IndicesArray{T,2,P,Tuple{I1,I2}}

"""
    IndicesVector{T,I}

Alias for one-dimensional `IndicesArray`  with elements of type `T`, parent of
type `P`, and index of type `I`. Alias for [`IndicesArray{T,1}`](@ref).
"""
const IndicesVector{T,P,I1} = IndicesArray{T,1,P,Tuple{I1}}

"""
    IVecOrMat{T}

Union type of [`IndicesVector{T}`](@ref) and [`IndicesMatrix{T}`](@ref).
"""
const IndicesVecOrMat{T} = Union{IndicesMatrix{T},IndicesVector{T}}

const IndicesAdjoint{T,P,I1,I2} = IndicesMatrix{T,Adjoint{T,P},I1,I2}

const IndicesTranspose{T,P,I1,I2} = IndicesMatrix{T,Transpose{T,P},I1,I2}

const IndicesDiagonal{T,V,I1,I2} = IndicesMatrix{T,Diagonal{T,V},I1,I2}

const IndicesQRCompactWY{T,P,I1,I2} = LinearAlgebra.QRCompactWY{T,IndicesMatrix{T,P,I1,I2}}

const IndicesQRPivoted{T,P,I1,I2} = QRPivoted{T,IndicesMatrix{T,P,I1,I2}}

const IndicesQR{T,P,I1,I2} = QR{T,IndicesMatrix{T,P,I1,I2}}

const IndicesQRUnion{T,P,I1,I2} = Union{IndicesQRCompactWY{T,P,I1,I2},
                                        IndicesQRPivoted{T,P,I1,I2},
                                        IndicesQR{T,P,I1,I2}}

_maybe_indices_array(x, inds::Tuple) = IndicesArray(x, inds, AllUnique, LengthChecked)
_maybe_indices_array(x, inds::Tuple{}) = x

function Base.empty!(a::IndicesArray)
    empty!(axes(a, 1))
    empty!(parent(a))
    return a
end
###
### Utilities
###
_catch_empty(x::Tuple) = x
_catch_empty(x::NamedTuple) = x
_catch_empty(::Tuple{}) = nothing
_catch_empty(::NamedTuple{(),Tuple{}}) = nothing

StaticRanges.Size(::Type{<:IndicesArray{T,N,P,I}}) where {T,N,P,I} = StaticRanges._Size(I)
