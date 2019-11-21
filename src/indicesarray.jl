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

_process_index(a, i, uc, lc) = Index(a, i, uc, lc)

_process_index(a, ::Nothing, uc, lc) = Index(a, uc)

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


Base.parent(x::IndicesArray) = getfield(x, :_parent)

Base.axes(x::IndicesArray) = getfield(x, :_indices)

Base.axes(x::IndicesArray, i::Int) = axes(x)[i]

Base.size(x::IndicesArray, i::Int) = length(axes(x, i))

Base.size(x::IndicesArray{T,N}) where {T,N} = map(i -> length(i), axes(x))

Base.parentindices(x::IndicesArray) = axes(parent(x))

axes_type(::T) where {T<:AbstractArray} = axes_type(T)
axes_type(::Type{IndicesArray{T,N,P,I}}) where {T,N,P,I} = I

parent_type(::T) where {T<:AbstractArray} = axes_type(T)
parent_type(::Type{IndicesArray{T,N,P,I}}) where {T,N,P,I} = P

###
### setindex!
###
@propagate_inbounds function Base.setindex!(a::IndicesArray, X, inds...)
    return unsafe_setindex!(parent(a), X, to_indices(axes(a), inds)...)
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
