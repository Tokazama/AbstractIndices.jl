"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{K,V,Ks<:AbstractVector{K},Vs<:AbstractUnitRange{V}} <: AbstractUnitRange{V} end

Base.valtype(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = V

values_type(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Vs

Base.keytype(::Type{<:AbstractIndex{K}}) where {K} = K

keys_type(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Ks

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))

Base.lastindex(a::AbstractIndex) = last(keys(a))

Base.haskey(a::AbstractIndex{K}, key::K) where {K} = key in keys(a)

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
    end
end

function set_length!(a::AbstractIndex, len::Int)
    can_set_length(a) || error("Cannot use set_length! for instances of typeof $(typeof(x)).")
    set_length!(keys(a), len)
    set_length!(values(a), len)
    return a
end
