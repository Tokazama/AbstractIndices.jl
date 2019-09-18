"""
    AxisIndex
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


