# TODO would `findkey` be a better name
findkeys(k::AbstractRange{K}, i::K) where {K} = round(Integer, (i - first(k)) / step(k) + 1)

findkeys(ks::OrdinalRange{K}, i::K) where K = div((i - first(ks)) + 1, step(ks))

findkeys(ks::AbstractUnitRange{K}, i::K) where K = (i - first(ks)) + 1

@inline function findkeys(ks::NTuple{N,K}, i::K) where {N,K}
    for idx in 1:N
        getfield(ks, idx) === i && return idx
    end
    return 0
end

findkeys(ks::AbstractVector{K}, i::K) where {K} = findfirst(isequal(i), ks)


findkeys(k::AbstractUnitRange{K}, inds::AbstractUnitRange{K}) where {K} = findkeys(k, first(inds)):findkeys(k, last(inds))

function findkeys(k::AbstractRange{K}, inds::AbstractRange{K}) where {K}
    s = div(step(inds), step(k))
    if isone(s)
        UnitRange(findkeys(k, first(inds)), findkeys(k, last(inds)))
    else
        return findkeys(k, first(inds)):round(Integer, s):findkeys(k, last(inds))
    end
end

findkeys(::OneTo{K}, i::K) where {K} = i

findkeys(k::TupOrVec{K}, inds::TupOrVec{K}) where {K} = map(i -> findkeys(k, i), inds)

