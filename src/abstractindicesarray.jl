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
function Base.dropdims(a::AbstractIndicesArray; dims)
    return similar(a, dropdims(parent(a); dims=dims), dropaxes(a, dims))
end

function Base.permutedims(a::AbstractIndicesArray, perm)
    return similar(a, dropdims(parent(a); dims=dims), permuteaxes(a, dims))
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

Base.zero(a::AbstractIndicesArray) = similar(a, zero(parent(a)), axes(a))

Base.one(a::AbstractIndicesArray) = similar(a, one(parent(a)), axes(a))

Base.copy(a::AbstractIndicesArray) = similar(a, copy(parent(a)), axes(a))



#= TODO
:sort, :sort!
mapslices
selectdim

broadcasting
copyto

reverse
iterate

reshape
=#
