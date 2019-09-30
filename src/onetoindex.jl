"""
    OneToIndex

An `AbstractIndex` subtype that maps directly to a `OneTo` range.
"""
struct OneToIndex{K,V,Ks} <: AbstractOneTo{K,V,Ks}
    _keys::Ks

    function OneToIndex{K,V,Ks}(keys::Ks, ::CheckedUnique{false}) where {K,V,Ks}
        allunique(keys) || error("Not all elements in keys were unique.")
        typeof(axes(keys, 1)) <: OneTo || error("OneToIndex requires keys with an index OneTo.")
        new{K,V,Ks}(keys)
    end

    function OneToIndex{K,V,Ks}(ks::Ks, ::CheckedUnique{true}) where {K,V,Ks}
        typeof(axes(ks, 1)) <: OneTo || error("OneToIndex requires keys with an index OneTo.")
        new{K,V,Ks}(ks)
    end

    OneToIndex{K,V,Tuple{K}}(ks::Tuple{K}) where {K,V} = new{K,V,Tuple{K}}(ks)
end

const OneIndex{K,V} = OneToIndex{K,V,Tuple{K}}

OneIndex(a::Real) = OneIndex{typeof(a),Int}((a,))

reduceaxis(a::UnitRangeIndex{K,V}) where {K<:Number,V} = OneIndex{K,V}((one(K),))


OneToIndex(ks::OneToIndex) = ks
OneToIndex(ks::TupOrVec{K}) where {K} = OneToIndex{K,Int,typeof(ks)}(ks, CheckedUniqueFalse)
OneToIndex(ks::TupOrVec{K}, ::OneTo{V}) where {K,V} = OneToIndex{K,V,typeof(ks)}(ks, CheckedUniqueFalse)
OneToIndex(ks::AbstractRange{K}, ::OneTo{V}) where {K,V} = OneToIndex{K,V,typeof(ks)}(ks, CheckedUniqueTrue)
OneToIndex(ks::OneToIndex{K,V}, ::OneTo{V}) where {K,V} = ks
function OneToIndex(ks::OneToIndex{K,V1,Ks}, ::OneTo{V2}) where {K,V1,Ks,V2}
    OneToIndex{K,V2,Ks}(keys(ks), CheckedUniqueTrue)
end

keys(x::OneToIndex) = x._keys

# we know all keys are unique because they are a copy of previously checked keys
function Base.similar(a::OneToIndex{K,V,Ks}, v::Type=V) where {K,V,Ks}
    OneToIndex{K,v,Ks}(copy(keys(a)), CheckedUniqueTrue)
end

function Base.resize!(a::OneToIndex{K,V,Ks}, i::Integer) where {K,V,Ks<:AbstractVector{K}}
    resize!(keys(a), i)
end
