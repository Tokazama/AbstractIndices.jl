"""
    AbstractIndicesArray

"""
abstract type AbstractIndicesArray{T,N,A<:Tuple{Vararg{<:AbstractIndex,N}},D<:AbstractArray{T,N}} <: AbstractArray{T,N} end

const AbstractIndicesMatrix{T,A,D} = AbstractIndicesArray{T,2,A,D}

const AbstractIndicesVector{T,A,D} = AbstractIndicesArray{T,1,A,D}

const AbstractIndicesMatOrVec{T,A,D} = Union{AbstractIndicesMatrix{T,A,D},AbstractIndicesVector{T,A,D}}

const AbstractIndicesAdjoint{T,A,D<:AbstractVector{T}} = AbstractIndicesMatrix{T,A,Adjoint{T,D}}

const AbstractIndicesTranspose{T,A,D<:AbstractVector{T}} = AbstractIndicesMatrix{T,A,Transpose{T,D}}

Base.size(a::AbstractIndicesArray) = size(parent(a))
Base.size(a::AbstractIndicesArray, i::Any) = size(parent(a), i)

Base.isempty(a::AbstractIndicesArray) = isempty(parent(a))

Base.length(a::AbstractIndicesArray) = length(parent(a))


#= TODO think about what makes sense for setting in indices
function Base.setindex!(ai::AxisIndex, val::Any, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds setindex!(to_index(ai), val, to_index(ai, i))
end
=#
Base.getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i::CartesianIndex{N}) where {T,N}
    getindex(parent(a), to_indices(a, i.I))
end

function Base.getindex(a::AbstractIndicesArray{T,1}, i::Any) where T
    @boundscheck checkbounds(a, i)
    @inbounds getindex(parent(a), i)
end

function Base.getindex(a::AbstractIndicesArray{T,N}, i::Vararg{Any,N}) where {T,N}
    @boundscheck checkbounds(a, i...)
    @inbounds _getindex(typeof(a), parent(a), axes(a), i...)
end

function _getindex(::Type{A}, a::AbstractArray{T,N}, axs::Tuple{Vararg{<:AbstractIndex,N}}, i::Tuple{Vararg{Any,N}}) where {A<:AbstractIndicesArray,T,N}
    maybe_indicesarray(A, a[map(to_index, axs, i)...], _drop_empty(map(getindex, axs, i)))
end

maybe_indicesarray(::Type{A}, a::AbstractArray, axs::Tuple) where {A<:AbstractIndicesArray} = similar(A, a, axs)

maybe_indicesarray(::Type{A}, a::Any, axs::Tuple{}) where {A<:AbstractIndicesArray} = a


function _drop_empty(x::Tuple)
    if length(first(x)) > 1
        (first(x), _drop_empty(tail(x))...)
    else
        _drop_empty(tail(x))
    end
end

_drop_empty(x::Tuple{}) = ()

function Base.dropdims(a::AbstractIndicesArray; dims)
    d = to_dim(a, dims)
    return similar(a, dropdims(parent(a); dims=d), map(i -> getindex(axes(a), i), d))
end

function Base.permutedims(a::AbstractIndicesArray, perm)
    return _permutedims(a, to_dim(a, perm))
end

function _permutedims(a::AbstractIndicesArray{T,N}, perm::NTuple{N,Int}) where {T,N}
end

for f in (
    :(Base.transpose),
    :(Base.adjoint),
    :(Base.permutedims),
    :(LinearAlgebra.pinv))

    # Vector
    @eval function $f(a::AbstractIndicesVector)
        similar(a, $f(parent(a)), (SingleIndex(a), axes(a, 1)))
    end

    # Vector Double Transpose
    if f !== :permutedims
        @eval begin
            function $f(a::Union{AbstractIndicesAdjoint,AbstractIndicesTranspose})
                similar(a, $f(parent(a)), (axes(a, 2),))
            end
        end
    end

    # Matrix
    @eval function $f(a::AbstractIndicesMatrix)
        similar(a, $f(parent(a)), (axes(a, 2), axes(a, 1)))
    end
end


#= TODO
mapslices
selectdim

broadcasting
copyto

reverse
iterate

reduce
mapreduce
sum
prod
maximum
minimum
mean
std
var

median
reshape
=#
