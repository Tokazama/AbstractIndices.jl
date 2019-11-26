"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{name,K,V<:Integer,Ks<:AbstractVector{K},Vs<:AbstractUnitRange{V}} <: AbstractUnitRange{V} end

Base.valtype(::Type{<:AbstractIndex{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = V

values_type(::T) where {T} = values_type(T)
values_type(::Type{<:AbstractIndex{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Vs

Base.keytype(::Type{<:AbstractIndex{name,K}}) where {name,K} = K

keys_type(::T) where {T} = keys_type(T)
keys_type(::Type{<:AbstractIndex{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Ks

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))

Base.lastindex(a::AbstractIndex) = last(keys(a))

Base.haskey(a::AbstractIndex{name,K}, key::K) where {name,K} = key in keys(a)

Base.allunique(a::AbstractIndex) = true

Base.length(a::AbstractIndex) = length(values(a))

Base.isempty(a::AbstractIndex) = isempty(values(a))

Base.in(a, itr::AbstractIndex) = in(x, values(a))

Base.eachindex(a::AbstractIndex) = keys(a)

Base.pairs(a::AbstractIndex) = Base.Iterators.Pairs(a, keys(a))

function StaticRanges.is_dynamic(::Type{T}) where {T<:AbstractIndex}
    return is_dynamic(values_type(T)) & is_dynamic(keys_type(T))
end

function StaticRanges.is_fixed(::Type{T}) where {T<:AbstractIndex}
    return is_fixed(values_type(T)) & is_fixed(keys_type(T))
end

function StaticRanges.is_static(::Type{T}) where {T<:AbstractIndex}
    return is_static(values_type(T)) & is_static(keys_type(T))
end

function StaticRanges.can_set_first(::Type{T}) where {T<:AbstractIndex}
    return can_set_first(values_type(T)) & can_set_first(keys_type(T))
end

function StaticRanges.can_set_last(::Type{T}) where {T<:AbstractIndex}
    return can_set_last(values_type(T)) & can_set_last(keys_type(T))
end

function StaticRanges.can_set_length(::Type{T}) where {T<:AbstractIndex}
    return can_set_length(values_type(T)) & can_set_length(keys_type(T))
end

# FIXME
Base.Slice(a::AbstractIndex) = x

for (f) in (:(==), :\, :isequal)
    @eval begin
        Base.$(f)(a::AbstractIndex, b::AbstractIndex) = $(f)(values(a), values(b))
        Base.$(f)(a::AbstractIndex, b::AbstractVector) = $(f)(values(a), b)
        Base.$(f)(a::AbstractVector, b::AbstractIndex) = $(f)(a, values(b))
        Base.$(f)(a::AbstractIndex, b::OrdinalRange) = $(f)(values(a), b)
        Base.$(f)(a::OrdinalRange, b::AbstractIndex) = $(f)(a, values(b))
    end
end

for f in (:+, :-)
    @eval begin
        function Base.$(f)(x::AbstractIndex, y::AbstractIndex)
            if same_type(x, y)
                return similar_type(x)(combine_keys(x, y), +(values(x), values(y)))
            else
                return $(f)(promote(x, y)...)
            end
        end

        Base.$(f)(x::AbstractIndex, y::AbstractVector) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractVector, y::AbstractIndex) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractIndex, y::AbstractUnitRange) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractUnitRange, y::AbstractIndex) = $(f)(promote(x, y)...)
    end
end



function set_length!(a::AbstractIndex, len::Int)
    can_set_length(a) || error("Cannot use set_length! for instances of typeof $(typeof(x)).")
    set_length!(keys(a), len)
    set_length!(values(a), len)
    return a
end

"""
    index_keys_type(values)

Returns the appropriate keys type for an index given the values. If `values` is
already and `AbstractIndex` then it returns the same as `keys_type`.

```
julia> index_keys_type(1:10)
Base.OneTo(10)

julia> index_keys_type(mrange(1, 10))
OneToMRange(10)

julia> index_keys_type(srange(1, 10))
OneToSRange(10)
```
"""
index_keys_type(::T) where {T<:AbstractIndex} = keys_type(T)
index_keys_type(::T) where {T} = index_keys_type(T)
function index_keys_type(::Type{T}) where {T<:AbstractUnitRange}
    if is_static(T)
        return OneToSRange{Int}
    elseif is_fixed(T)
        return OneTo{Int}
    else
        return OneToMRange{Int}
    end
end

#StaticRanges.Size(::Type{T}) = {T<:AbstractIndex} = Size(values_type(T))

const OneToIndex{name,K,V,Ks} = AbstractIndex{name,K,V,Ks,OneTo{V}}

const OneToMIndex{name,K,V,Ks} = AbstractIndex{name,K,V,Ks,OneToMRange{V}}

const OneToSIndex{name,K,V,Ks,L} = AbstractIndex{name,K,V,Ks,OneToSRange{V,L}}

const OffsetIndex{name,K,V,Ks} = AbstractIndex{name,K,V,Ks,UnitRange{V}}

const OffsetMIndex{name,K,V,Ks} = AbstractIndex{name,K,V,Ks,UnitMRange{V}}

const OffsetSIndex{name,K,V,Ks,F,L} = AbstractIndex{name,K,V,Ks,UnitSRange{V,F,L}}
