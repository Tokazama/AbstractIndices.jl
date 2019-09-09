function Base.getindex(ai::AbstractIndex, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds to_index(ai, i)
end

Base.getindex(x::AbstractIndex, i::Colon) = x



#= TODO think about what makes sense for setting in indices
function Base.setindex!(ai::AxisIndex, val::Any, i::Any)
    @boundscheck checkbounds(ai, i)
    @inbounds setindex!(to_index(ai), val, to_index(ai, i))
end
=#

"""
    setaxis!(A::AxisIndex, val, i)

The equivalent of `setindex` for the axis values of `A`.
"""
function setaxis!(ai::AbstractIndex, val::Any, i::Any)
    @boundscheck checkbounds(to_axis(ai), i)
    @inbounds setindex!(to_axis(ai), val, to_index(to_axis(ai), i))
end

Base.getindex(a::AbstractIndicesArray{T,N}, i::Colon) where {T,N} = a

function Base.getindex(a::AbstractIndicesArray{T,N}, i::CartesianIndex{N}) where {T,N}
    getindex(parent(a), to_indices(a, i.I))
end

function Base.getindex(a::AbstractIndicesArray{T,1}, i::Any) where T
    @boundscheck checkbounds(a, i)
    @inbounds getindex(parent(a), to_index(axes(a, 1), i))
end

function Base.getindex(a::AbstractIndicesArray{T,N}, i::Vararg{Any,N}) where {T,N}
    @boundscheck checkbounds(a, i...)
    @inbounds maybe_indicesarray(a, getindex(parent(a), to_indices(a, axes(a), i)...), i)
end

function Base.getindex(a::AbstractIndicesVector, i::Any)
    maybe_indicesarray(a, getindex(parent(a), to_index(a, i)), i)
end

function maybe_indicesarray(a::AbstractIndicesArray{T}, p::AbstractArray{T}, inds::Tuple) where T
    IndicesArray(p, _new_sub_axes(a, inds))
end

function _new_sub_axes(a::Tuple, inds::Tuple{<:Union{AbstractVector,Tuple},Vararg})
    (getindex(first(a), first(inds)), _new_sub_axes(tail(a), tail(inds))...)
end

function _new_sub_axes(a::Tuple, inds::Tuple{Colon,Vararg})
    (first(a), _new_sub_axes(tail(a), tail(inds))...)
end

function _new_sub_axes(a::Tuple, inds::Tuple{Union{Symbol,Number,AbstractString},Vararg})
    (_new_sub_axes(tail(a), tail(inds))...,)
end

_new_sub_axes(a::Tuple{}, inds::Tuple{}) = ()

function _new_sub_axes(a::Tuple, inds::Tuple{Any,Vararg})
    subax = getindex(first(a), first(inds))
    if length(subax) < 2
        (_new_sub_axes(tail(a), tail(inds))...,)
    else
        (subax, _new_sub_axes(tail(a), tail(inds))...)
    end
end



maybe_indicesarray(a::AbstractIndicesArray{T}, p::T, inds) where T = p

function Base.CartesianIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N}
    CartesianIndices(to_index.(axs))
end
