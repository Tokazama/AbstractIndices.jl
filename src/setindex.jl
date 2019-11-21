Base.@propagate_inbounds function Base.setindex!(
    A::AbstractArray{T,N},
    val,
    i::Vararg{AbstractIndex,N}
   ) where {T,N}
    setindex!(A, to_indices(A, i))
end
