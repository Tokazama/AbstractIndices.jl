"""
    HasDimNames
"""
struct HasDimNames{T} end
const HDNTrue = HasDimNames{true}()
const HDNFalse = HasDimNames{false}()

HasDimNames(x::T) where T = HasDimNames(T)
HasDimNames(::Type{T}) where T = HDNFalse

HasDimNames(::Type{T}) where {T<:NamedDimsArray} = HDNTrue

no_dimnames_error(a) = error("Type of $(typeof(a)) has no dimension names.")

"""
    HasAxes
"""
struct HasAxes{T} end

const HATrue = HasAxes{true}()
const HAFalse = HasAxes{false}()

HasAxes(x::T) where T = HasAxes(T)
HasAxes(::Type{T}) where T = HAFalse
HasAxes(::Type{T}) where T<:AbstractArray = HATrue

const NamedIndicesArray{L,T,N,Ax,D} = NamedDimsArray{L,T,N,IndicesArray{T,N,Ax,D}}

const NamedIndicesMatrix{L,T,Ax1,Ax2,D<:AbstractMatrix{T}} = NamedIndicesArray{L,T,2,Tuple{Ax1,Ax2},D}

const NamedIndicesVector{L,T,Ax1,D<:AbstractVector{T}} = NamedIndicesArray{L,T,1,Tuple{Ax1},D}

function NamedIndicesArray(a::AbstractArray, axs::NamedAxes)
    NamedDimsArray(IndicesArray(a, axs), dimnames(axs))
end

NamedIndicesArray(a::AbstractIndicesArray) = NamedDimsArray(a, dimnames(a))

NamedIndicesArray(a::AbstractArray; kwargs...) = NamedIndicesArray(a, NamedAxes(; kwargs...))


# FIXME: I had to define these functions to get test to pass but I assume that
# this should be possible to handle solely within NamedDims
Base.:(==)(a::NamedDimsArray, b::AbstractIndicesArray) = parent(a) == parent(b)
Base.:(==)(b::AbstractIndicesArray, a::NamedDimsArray) = parent(a) == parent(b)


Base.has_offset_axes(a::NamedIndicesArray) = has_offset_axes(parent(a))

Statistics.cov(a::NamedIndicesVector) = Statistics.cov(parent(parent(a)))

