"""
    SimpleIndex
"""
struct SimpleIndex{name,V,Vs<:AbstractUnitRange{V}} <: AbstractIndex{name,V,V,Vs,Vs}
    _kv::Vs
end

###
### Interface
###

Base.values(si::SimpleIndex) = getfield(si, :_kv)

Base.keys(si::SimpleIndex) = getfield(si, :_kv)

unname(idx::SimpleIndex) = SimpleIndex(keys(idx))

function unsafe_reindex(a::SimpleIndex{name}, inds::AbstractVector) where {name}
    return SimpleIndex{name}(_reindex(values(a), inds))
end

###
### pop
###
Base.pop!(si::SimpleIndex) = pop!(values(si))
function StaticRanges.pop(si::SimpleIndex)
    can_set_last(a) || error("Cannot change size of index of type $(typeof(a)).")
    return SimpleIndex{dimnames(si)}(pop(values(si)))
end

Base.popfirst!(si::SimpleIndex) = popfirst!(values(si))
function StaticRanges.popfirst(si::SimpleIndex)
    can_set_first(a) || error("Cannot change size of index of type $(typeof(a)).")
    return SimpleIndex{dimnames(si)}(popfirst(values(si)))
end


###
### Traits
###

StaticRanges.is_dynamic(::Type{T}) where {T<:SimpleIndex} = is_dynamic(keys_type(T))

StaticRanges.is_fixed(::Type{T}) where {T<:SimpleIndex} = is_fixed(keys_type(T))

StaticRanges.is_static(::Type{T}) where {T<:SimpleIndex} = is_static(keys_type(T))

StaticRanges.can_set_first(::Type{T}) where {T<:SimpleIndex} = can_set_first(keys_type(T))

StaticRanges.can_set_last(::Type{T}) where {T<:SimpleIndex} =  can_set_last(keys_type(T))

StaticRanges.can_set_length(::Type{T}) where {T<:SimpleIndex} = can_set_length(keys_type(T))

function StaticRanges.set_length!(a::SimpleIndex, len::Int)
    can_set_length(a) || error("Cannot use set_length! for instances of typeof $(typeof(x)).")
    set_length!(keys(a), len)
    return a
end

index_by(a::SimpleIndex{name,K}, i::K) where {name,K<:Integer} = ByValue
index_by(a::SimpleIndex{name,K}, i::AbstractVector{K}) where {name,K<:Integer} = ByValue
index_by(a::SimpleIndex{name,K}, i::I) where {name,K,I<:Integer} = ByValue
index_by(a::SimpleIndex{name,K}, i::AbstractVector{I}) where {name,K,I<:Integer} = ByValue

###
### show
###
function Base.show(io::IO, si::SimpleIndex)
    if isnothing(dimnames(idx))
        print(io, "SimpleIndex($(keys(si)))")
    else
        print(io, "SimpleIndex{$(dimnames(idx))}($(keys(idx)))")
    end
end
