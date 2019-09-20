"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{K,V} <: AbstractVector{V} end

Base.valtype(::Type{<:AbstractIndex{K,V}}) where {K,V} = V

Base.keytype(::Type{<:AbstractIndex{K,V}}) where {K,V} = K

Base.length(a::AbstractIndex) = length(values(a))

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))

"""
    stepindex(x) -> Real

Returns the step size of the index.
"""
stepindex(a::AbstractIndex) = step(keys(a))

Base.lastindex(a::AbstractIndex) = last(keys(a))

Base.iterate(a::AbstractIndex) = iterate(values(a))

Base.iterate(a::AbstractIndex, state) = iterate(values(a), state)

Base.pairs(a::AbstractIndex) = Base.Iterators.Pairs(a, keys(a))

Base.eachindex(a::AbstractIndex) = values(a)

unname(a::AbstractIndex) = a

"""
    SingleIndex

Represents a single point along an index. Useful for dimensions of length 1.
"""
struct SingleIndex{K,V} <: AbstractIndex{K,V}
    _key::K
    _val::V
end

Base.length(::SingleIndex) = 1

keys(si::SingleIndex) = si._key
values(si::SingleIndex) = si._val

SingleIndex(a::AbstractIndex{K,V}) where {K,V} = SingleIndex(one(K),one(V))


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



"""
    AxisIndex

A flexible subtype of `AbstractIndex` that facilitates mapping from a
collection keys ("axis") to a collection of values ("index").
"""
struct AxisIndex{K,V,KV,VV} <: AbstractIndex{K,V}
    _keys::KV
    _values::VV

    function AxisIndex{K,V,KV,VV}(keys::KV, values::VV) where {K,V,KV<:TupOrVec,VV<:TupOrVec}
        index_checks(keys, values)
        new{K,V,KV,VV}(keys, values)
    end
end

function AxisIndex(keys::TupOrVec{K}, values::TupOrVec{V}) where {K,V}
    AxisIndex{K,V,typeof(keys),typeof(values)}(keys, values)
end

AxisIndex(keys::TupOrVec) = AxisIndex(keys, axes(keys, 1))

keys(x::AxisIndex) = x._keys
values(x::AxisIndex) = x._values

"""
    StaticKeys

A set of unique keys that are known at compile time for indexing. A
`StaticKeys` index always refers back to a one based indexing system.
"""
struct StaticKeys{Keys,K} <: AbstractIndex{K,Int}

    function StaticKeys{Keys,K}() where {Keys,K}
        eltype(Keys) <: K || error("eltype of $(Keys) is not match provided keytype $(K)")
        new{Keys,K}()
    end
end

StaticKeys(Keys::NTuple{N,K}) where {N,K} = StaticKeys{Keys,K}()

values(sk::StaticKeys) = OneTo(length(sk))
keys(sk::StaticKeys{Keys}) where {Keys} = Keys
length(sk::StaticKeys) = length(keys(sk))

"""
    NamedIndex

A subtype of `AbstractIndex` with a name.
"""
struct NamedIndex{name,K,V,I<:AbstractIndex{K,V}} <: AbstractIndex{K,V}
    index::I
end

keys(ni::NamedIndex) = keys(ni.index)
values(ni::NamedIndex) = values(ni.index)
dimnames(::NamedIndex{name}) where {name} = name
unname(ni::NamedIndex) = ni.index

# TODO revisit this constructor. seems a bit odd but might be nice to have
(name::Symbol)(a::AbstractIndex) = NamedIndex{name}(a)

NamedIndex{name}(ni::AbstractVector) where {name} = NamedIndex{name}(asindex(ni))
NamedIndex{name}(ni::AbstractIndex{K,V}) where {name,K,V} = NamedIndex{name,K,V,typeof(ni)}(ni)
NamedIndex{name}(ni::NamedIndex{name,K,V}) where {name,K,V} = ni


const TupleIndices{N} = Tuple{Vararg{<:AbstractIndex,N}}

"""

    asindex(keys[, values])

Chooses the most appropriate index type for an keys and index set.
"""
asindex(keys::TupOrVec, index::TupOrVec) = AxisIndex(keys, index)

asindex(keys::TupOrVec, ::OneTo) = OneToIndex(keys)

asindex(keys::NTuple{N}) where {N} = asindex(keys, OneTo(N))

asindex(keys::NTuple{N,Symbol}, index::AbstractVector) where {N} = LabelIndex(keys, index)

function asindex(keys::NTuple{N,T}, index::AbstractVector) where {N,T}
    if isbitstype(T)
        LabelIndex(keys, index)
    else
        asindex([keys...])
    end
end

asindex(keys::AbstractVector) = asindex(keys, axes(keys, 1))

asindex(a::AbstractIndex) = a


# TODO Is this the best way to handle this?
Base.UnitRange(a::AbstractIndex) = UnitRange(keys(a))
