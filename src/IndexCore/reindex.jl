"""
    reindex(a::AbstractIndex, inds::AbstractVector{Integer}) -> AbstractIndex

Returns and index of the same type as `a` where the keys the new keys are
constructed by indexing into the keys of `a` with `inds` and the values have the
same starting value but a length matching `inds`. This is the final call 
"""
function reindex(a::AbstractIndex, inds::AbstractVector{Integer})
    @boundscheck checkbounds(a, inds)
    return unsafe_reindex(a, inds)
end

"""
    unsafe_reindex(a::AbstractIndex, inds::AbstractVector) -> AbstractIndex

Similar to `reindex` this function returns an index of the same type as `a` but
doesn't check that `inds` is inbounds.

See also: [`reindex`](@ref)
"""
function unsafe_reindex(a::AbstractIndex, inds::AbstractVector)
    return similar_type(a)(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))

_reindex(a::UnitRange{T}, inds) where {T} = UnitRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitMRange{T}, inds) where {T} = UnitMRange{T}(first(a), first(a) + length(inds) - 1)
_reindex(a::UnitSRange{T}, inds) where {T} = UnitSRange{T}(first(a), first(a) + length(inds) - 1)
