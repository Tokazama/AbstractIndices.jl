

to_index(a::AbstractIndex{K,V}, i::K) where {K,V} = getindex(values(a), _to_index(keys(a), i))

# ketype is not Int so assume user wants to directly go to index
to_index(a::AbstractIndex{K,V}, i::Int) where {K,V} = getindex(values(a), i)

# keytype is Int so assume user is interfacing to index through the axis
to_index(a::AbstractIndex{Int,V}, i::Int) where {K,V} = getindex(values(a), _to_index(keys(a), i))

to_index(a::AbstractIndex{K,V}, i::CartesianIndex{1}) where{K,V} = getindex(values(a), i)

to_index(a::AbstractIndex{K,V}, inds::TupOrVec{K}) where {K,V} = getindex(values(a), _to_index(keys(a), inds))

to_index(a::AbstractIndex{Int,V}, inds::TupOrVec{Int}) where {V} = getindex(values(a), _to_index(keys(a), inds))

to_index(a::AbstractIndex{K,V}, inds::TupOrVec{Int}) where {K,V} = getindex(values(a), inds)

to_index(a::AbstractIndex{K,V}, inds::Colon) where {K,V} = values(a)

_to_index(k::AbstractVector{K}, i::K) where {K} = findfirst(isequal(i), k)
function _to_index(k::NTuple{N,K}, idx::K) where {N,K}
    for i in 1:N
        getfield(k, i) === idx && return i
    end
    return 0
end

_to_index(k::TupOrVec, inds::TupOrVec) = map(i -> _to_index(k, i), inds)

# TODO double check this
_to_index(k::AbstractRange, inds::AbstractRange) = findfirst(k, first(inds)):round(Integer, step(inds) * step(k)):findfirst(k, last(inds))


