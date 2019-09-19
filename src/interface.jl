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

function NamedIndicesArray(a::AbstractArray, axs::NamedAxes)
    IndicesArray(NamedDimsArray(dimnames(axs), a), unname(axs))
end

NamedIndicesArray(a::AbstractArray; kwargs...) = NamedIndicesArray(a, NamedAxes(; kwargs...))
