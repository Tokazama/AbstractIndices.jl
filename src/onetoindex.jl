"""
    OneToIndex

An `AbstractIndex` subtype that maps directly to a `OneTo` range. Conversion of
any `AbstractVector
"""
struct OneToIndex{K,KV} <: AbstractIndex{K,Int}
    _keys::KV

    function OneToIndex{K,KV}(keys::KV) where {K,KV}
        allunique(keys) || error("Not all elements in axis were unique.")
        typeof(axes(keys, 1)) <: OneTo || error("OneToIndex requires an axis with a OneTo index.")
        new{K,KV}(keys)
    end
end

OneToIndex(keys::TupOrVec{K}) where {K} = OneToIndex{K,typeof(keys)}(keys)

length(x::OneToIndex) = length(keys(x))

values(x::OneToIndex) = OneTo(length(x))
values(x::OneToIndex, i::Int) = i
keys(x::OneToIndex) = x._keys

function show(io::IO, ::MIME"text/plain", x::OneToIndex{K,<:AbstractRange}) where {K}
    print(io, "OneToIndex($(keys(x)))")
end

