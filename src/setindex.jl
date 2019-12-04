Base.@propagate_inbounds function Base.setindex!(
    A::AbstractArray{T,N},
    val,
    i::Vararg{AbstractIndex,N}
   ) where {T,N}
    setindex!(A, to_indices(A, i))
end

# Base.@propagate_inbounds function Base.setindex!(A::IndicesArray) end

for f in (:getindex, :view, :dotview)
    @eval begin
        @propagate_inbounds function Base.$f(A::NamedDimsArray; named_inds...)
            inds = order_named_inds(A; named_inds...)
            return Base.$f(A, inds...)
        end

        @propagate_inbounds function Base.$f(a::NamedDimsArray, inds::Vararg{<:Integer})
            # Easy scalar case, will just return the element
            return Base.$f(parent(a), inds...)
        end

        @propagate_inbounds function Base.$f(a::NamedDimsArray, ci::CartesianIndex)
            # Easy scalar case, will just return the element
            return Base.$f(parent(a), ci)
        end

        @propagate_inbounds function Base.$f(a::NamedDimsArray, inds...)
            # Some nonscalar case, will return an array, so need to give that names.
            data = Base.$f(parent(a), inds...)
            L = remaining_dimnames_from_indexing(dimnames(a), inds)
            return NamedDimsArray{L}(data)
        end
    end
end

############################################
# setindex!
@propagate_inbounds function Base.setindex!(a::NamedDimsArray, value; named_inds...)
    inds = order_named_inds(a; named_inds...)
    return setindex!(a, value, inds...)
end

@propagate_inbounds function Base.setindex!(a::NamedDimsArray, value, inds...)
    return setindex!(parent(a), value, inds...)
end
