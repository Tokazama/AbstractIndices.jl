"""
    IndicesArray
"""
struct IndicesArray{T,N,P<:AbstractArray{T,N},I<:NTuple{N,AbstractIndex}} <: AbstractArray{T,N}
    _parent::P
    _indices::I

    function IndicesArray{T,N,P,I}(parent, indices, uc, lc) where {T,N,P,I}
        check_index_params(parent, indices, uc, lc)
        new{T,N,P,I}(parent, indices)
    end
end

function IndicesArray(
    p::AbstractArray{T,N},
    inds::Tuple,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked,
   ) where {T,N}
    return IndicesArray{T,N,typeof(p)}(
        p,
        map((a, i) -> _process_index(a, i, uc, lc), axes(p), inds),
        AllUnique,
        LengthChecked
       )
end

function IndicesArray(p::AbstractArray{T,N}, axs::Tuple{Vararg{<:Union{Symbol,Nothing},N}}) where {T,N}
    IndicesArray{T,N,typeof(p)}(p, indices(p, axs), AllUnique, LengthChecked)
end

function IndicesArray(
    p::AbstractVector,
    inds::AbstractVector,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked,
   )
    return IndicesArray(p, (inds,), uc, lc)
end


function IndicesArray{T,N,P}(
    p::P,
    inds::I,
    uc::Uniqueness,
    lc::AbstractLengthCheck
   ) where {T,N,P<:AbstractArray{T,N},I}
    return IndicesArray{T,N,P,I}(p, inds, uc, lc)
end

#IndicesArray(p::AbstractArray) = IndicesArray(p, indices(p), AllUnique, LengthChecked)

function IndicesArray(x::AbstractArray{T,N}; kwargs...) where {T,N}
    if isempty(kwargs)
        return IndicesArray(x, axes(x), AllUnique, LengthChecked)
    else
        return IndicesArray(x, Tuple([Index{k}(v) for (k,v) in kwargs]))
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
    indices(x) -> Tuple
"""
indices(x::IndicesArray) = axes(x)

function indices(x::AbstractArray)
    if is_static(x)
        return map(i -> Index(OneToSRange(i)), size(x))
    elseif is_fixed(x)
        return map(i -> Index(OneTo(i)), size(x))
    else
        return map(i -> Index(OneToMRange(i)), size(x))
    end
end

function indices(x::AbstractArray{T,N}, dimnames::Tuple{Vararg{Union{Symbol,Nothing},N}}) where {T,N}
    if is_static(x)
        return map((d, s) -> Index{d}(OneToSRange(s)), dimnames, size(x))
    elseif is_fixed(x)
        return map((d, s) -> Index{d}(OneTo(s)), dimnames, size(x))
    else
        return map((d, s) -> Index{d}(OneToMRange(s)), dimnames, size(x))
    end
end


"""
    IndicesMatrix{T,P,I1,I2}

Alias for two-dimensional `IndicesArray`  with elements of type `T`, parent of
type `P`, and index of type `I1` and `I2`. Alias for [`IndicesArray{T,1}`](@ref).
"""
const IndicesMatrix{T,P<:AbstractMatrix{T},I1,I2} = IndicesArray{T,2,P,Tuple{I1,I2}}

"""
    IndicesVector{T,P,I}

Alias for one-dimensional `IndicesArray`  with elements of type `T`, parent of
type `P`, and index of type `I`. Alias for [`IndicesArray{T,1}`](@ref).
"""
const IndicesVector{T,P<:AbstractVector{T},I1} = IndicesArray{T,1,P,Tuple{I1}}

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

axes_type(::T) where {T<:AbstractArray} = axes_type(T)
axes_type(::Type{IndicesArray{T,N,P,I}}) where {T,N,P,I} = I

Base.parent(x::IndicesArray) = getfield(x, :_parent)

Base.axes(x::IndicesArray) = getfield(x, :_indices)

@propagate_inbounds Base.axes(a::IndicesArray, i) = unsafe_axes(axes(a), to_dim(a, i))
unsafe_axes(axs::Tuple, idx) = @inbounds(getindex(axs, idx))

@propagate_inbounds Base.size(a::IndicesArray, i) = length(axes(a, i))

Base.size(a::IndicesArray) = map(length, axes(a))

@inline Base.length(a::IndicesArray) = _length(axes(a))
_length(axs::Tuple{AbstractIndex,Vararg{Any}}) = length(first(axs)) * _length(tail(axs))
_length(axs::Tuple{AbstractIndex}) = length(first(axs))

Base.parentindices(x::IndicesArray) = axes(parent(x))

parent_type(::T) where {T<:AbstractArray} = axes_type(T)
parent_type(::Type{IndicesArray{T,N,P,I}}) where {T,N,P,I} = P

"""
    filter_axes(f, a)

Return the axes of `a`, removing those for which `f` is false. The function `f`
is passed one argument.
"""
filter_axes(f::Function, x::AbstractArray) = _catch_empty(_filter_axes(f, axes(x)))
function _filter_axes(f, t::Tuple)
    if f(first(t))
        return (first(t), _filter_axes(f, tail(t))...)
    else
        return _filter_axes(f, tail(t))
    end
end
_filter_axes(f, ::Tuple{}) = ()

"""
    find_axes(f, x)

Returns a tuple of indices for which the axes of `x` are true under `f`. If `x`
has named dimensions this is a tuple of symbols. Otherwise, a tuple of integers
is returned. If all axes return false under the conditions of `f` then
`nothing` is returned.
"""
find_axes(f::Function, a) = _find_axes(f, axes(a), 1)
function _find_axes(f::Function, axs::Tuple{Any,Vararg{Any}}, cnt::Int)
    if f(first(axs))
        return (cnt, _find_axes(f, tail(axs), cnt+1)...)
    else
        return _find_axes(f, tail(axs), cnt+1)
    end
end
_find_axes(f, ::Tuple{}, ::Int) = ()

###
### setindex!
###
@propagate_inbounds function Base.setindex!(a::IndicesArray, X, inds...)
    return unsafe_setindex!(parent(a), X, to_indices(axes(a), inds))
end

unsafe_setindex!(a, X, inds::Tuple) = @inbounds(setindex!(a, X, inds...))

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
