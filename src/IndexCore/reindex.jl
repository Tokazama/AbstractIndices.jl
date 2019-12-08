"""
    reindex(a::AbstractIndex, inds::AbstractVector{Integer}) -> AbstractIndex

Returns and index of the same type as `a` where the keys the new keys are
constructed by indexing into the keys of `a` with `inds` and the values have the
same starting value but a length matching `inds`.

## Examples
```jldoctest
julia> x, y, z = Index(1:10, 2:11), Index(1:10), SimpleIndex(1:10);

julia> reindex(x, collect(1:2:10))
Index([1, 3, 5, 7, 9] => 2:6)

julia> reindex(y, collect(1:2:10))
Index([1, 3, 5, 7, 9] => Base.OneTo(5))

julia> reindex(z, collect(1:2:10))
SimpleIndex(1:5)
```
"""
function reindex(a::AbstractIndex, inds::AbstractVector{T}) where {T<:Integer}
    @boundscheck checkbounds(a, inds)
    return unsafe_reindex(a, inds)
end

"""
    unsafe_reindex(a::AbstractIndex, inds::AbstractVector) -> AbstractIndex

Similar to `reindex` this function returns an index of the same type as `a` but
doesn't check that `inds` is inbounds. New subtypes of `AbstractIndex` must
implement a unique `unsafe_reindex` method.

See also: [`reindex`](@ref)
"""
function unsafe_reindex(a::AbstractIndex, inds)
    error("New subtypes of `AbstractIndex` must implement a unique `unsafe_reindex` method.")
end
function unsafe_reindex(a::Index{name}, inds) where {name}
    return Index{name}(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end
function unsafe_reindex(a::SimpleIndex{name}, inds) where {name}
    return SimpleIndex{name}(_reindex(values(a), inds))
end

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))
_reindex(a::T, inds) where {T<:AbstractUnitRange} = T(first(a), first(a) + length(inds) - 1)
