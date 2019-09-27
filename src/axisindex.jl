"""
    AxisIndex

A flexible subtype of `AbstractIndex` that facilitates mapping from a
collection keys ("axis") to a collection of values ("index").
"""
struct AxisIndex{K,V,Ks,Vs,IS} <: AbstractIndex{K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function AxisIndex{K,V,Ks,Vs,IS}(keys::Ks, values::Vs, ::CheckedUnique{false}) where {K,V,Ks,Vs,IS}
        allunique(axis) || error("Not all elements in axis were unique.")
        length(axis) == length(index) || error("axis and index lengths don't match, length(axis) = $(length(axis)) and length(index) = $(length(index))")
        new{K,V,Ks,Vs,IS}(keys, values)
    end

    function AxisIndex{K,V,Ks,Vs,IS}(keys::Ks, values::Vs, ::CheckedUnique{true}) where {K,V,Ks,Vs,IS}
        length(axis) == length(index) || error("axis and index lengths don't match, length(axis) = $(length(axis)) and length(index) = $(length(index))")
        new{K,V,Ks,Vs,IS}(keys, values)
    end
end

function AxisIndex(keys::TupOrVec{K}, values::AbstractUnitRange{V}) where {K,V}
    f = first(values)
    if isone(f)
        AxisIndex{K,V,typeof(keys),typeof(values),IndexBaseOne()}(keys, values, CheckedUniqueFalse)
    else
        AxisIndex{K,V,typeof(keys),typeof(values),IndexBaseOffset{f}()}(keys, values, CheckedUniqueFalse)
    end
end

AxisIndex(keys::TupOrVec) = AxisIndex(keys, axes(keys, 1))

IndexingStyle(::Type{<:AxisIndex{K,V,Ks,Vs,IS}}) where {K,V,Ks,Vs,IS} = IS

keys(x::AxisIndex) = x._keys
values(x::AxisIndex) = x._values

function Base.similar(a::AxisIndex{K,V,Ks,Vs}, vs::Type=V) where {K,V,Ks,Vs}
    AxisIndex(copy(keys(a)), similar(values(a), V), CheckedUniqueTrue)
end

# determined at time of construction
Base.allunique(::AxisIndex) = true

function asindex(ks::TupOrVec{K}, s::IndexBaseOffset) where {K}
    vs = UnitRange(offset(s), offset(s)+length(ks))
    return AxisIndex{K,eltype(vs),typeof(ks),typeof(vs),s}(ks, vs, CheckedUniqueFalse)
end
