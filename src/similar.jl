function StaticRanges.similar_type(
    ia::IndicesArray;
    axes_type::Type=axes_type(A),
    parent_type::Type=parent_type(A)
   )
    return _similar_type(ia, parent_type, axes_type)
end

function _similar_type(
    a::IndicesArray;
    new_axes_type::Type=axes_type(a),
    new_parent_type::Type=parent_type(a)
   )
    return IndicesArray{eltype(new_parent_type),ndims(new_parent_type),new_parent_type,new_axes_type}
end


#=
function Base.similar(
    a::IndicesArray{T},
    eltype::Type=T,
    axs=axes(a)
   ) where {T}
    return IndicesArray(similar(parent(a), eltype, map(length, axs)), _drop_empty(axs))
end
=#

function Base.similar(
    a::AbstractArray{T},
    eltype::Type,
    axs::Tuple{Vararg{<:AbstractIndex}}
   ) where {T}
    return IndicesArray(similar(a, eltype, map(length, axs)), _drop_empty(axs))
end

function Base.similar(
    ::Type{A},
    eltype::Type,
    axs::Tuple{Vararg{<:AbstractIndex}}
   ) where {A<:AbstractArray}
    return IndicesArray(similar(A, eltype, map(length, axs)), _drop_empty(axs))
end

function Base.similar(
    ::Type{A},
    axs::Tuple{Vararg{<:AbstractIndex}}
   ) where {A<:AbstractArray}
    return IndicesArray(similar(A, map(length, axs)), _drop_empty(axs))
end
