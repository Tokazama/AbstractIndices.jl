"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{K,V<:Integer,Ks,Vs<:AbstractUnitRange{V}} <: AbstractUnitRange{V} end

Base.valtype(::Type{<:AbstractIndex{K,V}}) where {K,V} = V

Base.keytype(::Type{<:AbstractIndex{K,V}}) where {K,V} = K

Base.has_offset_axes(a::AbstractIndex) = has_offset_axes(IndexingStyle(a))

Base.length(a::AbstractIndex) = length(values(a))

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))

Base.isempty(a::AbstractIndex) = length(a) == 0

Base.lastindex(a::AbstractIndex) = last(keys(a))

Base.pairs(a::AbstractIndex) = Base.Iterators.Pairs(a, keys(a))

Base.eachindex(a::AbstractIndex) = keys(a)

dimnames(a::AbstractIndex) = nothing

unname(a::AbstractIndex) = a

@inline function Base.:(==)(a::AbstractIndex, b::AbstractIndex)
    (keys(a) == keys(b)) & (values(a) == values(b))
end

@inline function Base.isequal(a::AbstractIndex, b::AbstractIndex)
    isequal(keys(a), keys(b)) & isequal(values(a), values(b))
end

Base.allunique(a::AbstractIndex) = allunique(keys(a))

Base.reverse(a::AbstractIndex) = asindex(reverse(keys(a)), reverse(values(a)))

###
###
###


###
### key2ind - necessary for reverse indexing
###
key2ind(k::AbstractRange{K}, i::K) where {K} = round(Integer, (i - first(k)) / step(k) + 1)

key2ind(ks::OrdinalRange{K}, i::K) where K = div((i - first(ks)) + 1, step(ks))

key2ind(ks::AbstractUnitRange{K}, i::K) where K = (i - first(ks)) + 1

@inline function key2ind(ks::NTuple{N,K}, i::K) where {N,K}
    for idx in 1:N
        getfield(ks, idx) === i && return idx
    end
    return 0
end

key2ind(ks::AbstractVector{K}, i::K) where {K} = findfirst(isequal(i), ks)


key2ind(k::AbstractUnitRange{K}, inds::AbstractUnitRange{K}) where {K} = key2ind(k, first(inds)):key2ind(k, last(inds))

function key2ind(k::AbstractRange{K}, inds::AbstractRange{K}) where {K}
    s = div(step(inds), step(k))
    if isone(s)
        UnitRange(key2ind(k, first(inds)), key2ind(k, last(inds)))
    else
        return key2ind(k, first(inds)):round(Integer, s):key2ind(k, last(inds))
    end
end

key2ind(::OneTo{K}, i::K) where {K} = i

key2ind(k::TupOrVec{K}, inds::TupOrVec{K}) where {K} = map(i -> key2ind(k, i), inds)

###
### to_index
###

to_index(a::AbstractIndex{K},   i::Colon) where {K}               = values(a)
to_index(a::AbstractIndex{K},   i::K) where {K}                   = getindex(values(a), key2ind(keys(a), i))
to_index(a::AbstractIndex{K},   i::Int) where {K}                 = getindex(values(a), i)
to_index(a::AbstractIndex{Int}, i::Int)                           = getindex(values(a), key2ind(keys(a), i))
to_index(a::AbstractIndex{K},   i::CartesianIndex{1}) where{K}    = getindex(values(a), i)

to_index(a::AbstractIndex{K},   i::AbstractVector{K}) where {K}   = getindex(values(a), key2ind(keys(a), i))
to_index(a::AbstractIndex{K},   i::AbstractVector{Int}) where {K} = getindex(values(a), i)
to_index(a::AbstractIndex{Int}, i::AbstractVector{Int})           = getindex(values(a), key2ind(keys(a), i))
to_index(a::AbstractIndex{K},   i::AbstractVector{CartesianIndex{1}}) where {K} = getindex(values(a), inds)


#to_index(a::AbstractVector, i::AbstractIndex) = getindex(a, values(i))

const TupleIndices{N} = Tuple{Vararg{<:AbstractIndex,N}}

###
### getindex
###

Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::Int) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    getindex(values(a), key2ind(keys(a), i))
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::K) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    getindex(values(a), key2ind(keys(a), i))
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::AbstractVector{Int}) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), key2ind(keys(a), i)), a)
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{K}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), key2ind(keys(a), i)), a)
end

# this is necessary to avoid ambiguities in base
Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::AbstractUnitRange{Int}) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), key2ind(keys(a), i)), a)
end

for (I) in (Int,CartesianIndex{1})
    @eval begin
        Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::$I) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            getindex(values(a), i)
        end

        Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{$I}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            asindex(getindex(keys(a), i), a)
        end
    end
end
