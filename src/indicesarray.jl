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

function IndicesArray(
    p::AbstractVector,
    inds::AbstractVector,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked,
   )
    return IndicesArray(p, (inds,), uc, lc)
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


function IndicesArray{T,N,P}(
    p::P,
    inds::I,
    uc::Uniqueness,
    lc::AbstractLengthCheck
   ) where {T,N,P<:AbstractArray{T,N},I}
    return IndicesArray{T,N,P,I}(p, inds, uc, lc)
end

IndicesArray(p::AbstractArray) = IndicesArray(p, indices(p), AllUnique, LengthChecked)

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

"""
    IndicesVector{T,P,I1,I2}

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
    IndicesVecOrMat{T}

Union type of [`IndicesVector{T}`](@ref) and [`IndicesMatrix{T}`](@ref).
"""
const IndicesVecOrMat{T} = Union{IndicesMatrix{T},IndicesVector{T}}

const IndicesAdjoint{T,P<:AbstractVector{T},I} = IndicesMatrix{T,Adjoint{T,P},I}

const IndicesTranspose{T,P<:AbstractVector{T},I} = IndicesMatrix{T,Transpose{T,P},I}

_maybe_indices_array(x, inds::Tuple) = IndicesArray(x, inds, AllUnique, LengthChecked)
_maybe_indices_array(x, inds::Tuple{}) = x

axes_type(::T) where {T<:AbstractArray} = axes_type(T)
axes_type(::Type{IndicesArray{T,N,P,I}}) where {T,N,P,I} = I

Base.parent(x::IndicesArray) = getfield(x, :_parent)

Base.axes(x::IndicesArray) = getfield(x, :_indices)

function to_dim(a::IndicesArray{T,N}, i::Int) where {T,N}
    @boundscheck if i < 1 || i > N
        throw(BoundsError(axes(a), i))
    end
    return i
end

function to_dim(a::Tuple{Vararg{Any,N}}, i::Int) where {N}
    @boundscheck if i < 1 || i > N
        throw(BoundsError(axes(a), i))
    end
    return i
end

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

# `sort` and `sort!` don't change the index, just as it wouldn't on a normal vector
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumprod, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::IndicesArray; dims, kwargs...)
            return IndicesArray($mod.$fun(parent(a), dims=dims, kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::IndicesVector; kwargs...)
            return IndicesArray($mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end

function Base.similar(
    a::IndicesArray{T},
    eltype::Type=T,
    axs=axes(a)
   ) where {T}
    return IndicesArray(similar(parent(a), eltype, map(length, axs)), _drop_empty(axs))
end

function Base.similar(
    a::AbstractArray{T},
    eltype::Type,
    axs::Tuple{Vararg{AbstractIndex}}
   ) where {T}
    return IndicesArray(similar(a, eltype, map(length, axs)), _drop_empty(axs))
end

function Base.similar(
    ::Type{A},
    eltype::Type,
    axs::Tuple{Vararg{AbstractIndex}}
   ) where {A<:AbstractArray}
    return IndicesArray(similar(A, eltype, map(length, axs)), _drop_empty(axs))
end

function Base.similar(
    ::Type{A},
    axs::Tuple{Vararg{AbstractIndex}}
   ) where {A<:AbstractArray}
    return IndicesArray(similar(A, map(length, axs)), _drop_empty(axs))
end
