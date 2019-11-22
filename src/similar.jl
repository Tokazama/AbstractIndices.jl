function Base.similar(
    a::IndicesArray{T,N,A,D,F},
    eltype::Type=T,
    new_axes::Tuple{Vararg{Union{<:AbstractIndex,AbstractPosition}}}=axes(a)
   ) where {T,N,A,D,F}

    return IndicesArray(similar(parent(a), eltype, length.(new_axes)), new_axes)
end

function StaticRanges.similar_type(::IndicesArray; parent::Type=parenttype(A), axes::Type=axestype(A), new_parent::Type=) where {A<:IndicesArray}
    IndicesArray{eltype(new_parent),ndims(new_parent),new_axes,new_parent}
end

function Base.similar(::Type{T}, dims::DimOrIndex...) where {T<:AbstractArray}
    similar(T, dims)
end

