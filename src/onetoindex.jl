"""
    OneToIndex

An `AbstractIndex` subtype that maps directly to a `OneTo` range. Conversion of
any `AbstractVector
"""
struct OneToIndex{K,V,Ks} <: AbstractIndex{K,V,Ks,OneTo{V}}
    _keys::Ks

    function OneToIndex{K,V,Ks}(keys::Ks) where {K,V,Ks}
        allunique(keys) || error("Not all elements in axis were unique.")
        typeof(axes(keys, 1)) <: OneTo || error("OneToIndex requires an axis with a OneTo index.")
        new{K,V,Ks}(keys)
    end
end

OneToIndex(keys::OneToIndex) = keys
OneToIndex(keys::TupOrVec{K}) where {K} = OneToIndex{K,Int,typeof(keys)}(keys)

length(x::OneToIndex) = length(keys(x))
values(x::OneToIndex) = OneTo(length(x))
values(x::OneToIndex, i::Int) = i
keys(x::OneToIndex) = x._keys

Base.allunique(::OneToIndex) = true  # determined at time of construction

Base.similar(a::OneToIndex{K,V,Ks}, v::Type=V) where {K,V,Ks} = OneToIndex{K,v,Ks}(copy(keys(a)))

IndexingStyle(::Type{<:OneToIndex}) = IdxOne

#= TODO: I should be able to delete this now
function getindex(a::OneToIndex{K,KV}, i::K) where {K,KV<:TupOrVec{K}}
    @boundscheck checkbounds(a, i)
    findfirst(isequal(i), keys(a))
end
=#

asindex(ks::TupOrVec, ::IndexBaseOne) = OneToIndex(ks)
