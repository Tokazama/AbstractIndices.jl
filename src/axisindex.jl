"""
    AxisIndex

A flexible subtype of `AbstractIndex` that facilitates mapping from a
collection keys ("axis") to a collection of values ("index").
"""
struct AxisIndex{K,V,Ks,Vs} <: AbstractIndex{K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function AxisIndex{K,V,Ks,Vs}(ks::Ks, vs::Vs, ::CheckedUnique{false}) where {K,V,Ks,Vs}
        allunique(ks) || error("Not all elements in axis were unique.")
        length(ks) == length(vs) || error("axis and index lengths don't match, length(keys) = $(length(vs)) and length(values) = $(length(ks))")
        new{K,V,Ks,Vs}(ks, vs)
    end

    function AxisIndex{K,V,Ks,Vs}(ks::Ks, vs::Vs, ::CheckedUnique{true}) where {K,V,Ks,Vs}
        length(ks) == length(vs) || error("axis and index lengths don't match, length(keys) = $(length(ks)) and length(values) = $(length(vs))")
        new{K,V,Ks,Vs}(keys, vs)
    end
end

function AxisIndex(ks::TupOrVec{K}, vs::AbstractUnitRange{V}) where {K,V}
    AxisIndex{K,V,typeof(ks),typeof(vs)}(ks, vs, CheckedUniqueFalse)
end

AxisIndex(ks::TupOrVec) = AxisIndex(ks, axes(ks, 1))

keys(x::AxisIndex) = x._keys
values(x::AxisIndex) = x._values

function Base.similar(a::AxisIndex{K,V,Ks,Vs}, vs::Type=V) where {K,V,Ks,Vs}
    AxisIndex(copy(keys(a)), similar(values(a), V), CheckedUniqueTrue)
end

# determined at time of construction
Base.allunique(::AxisIndex) = true
