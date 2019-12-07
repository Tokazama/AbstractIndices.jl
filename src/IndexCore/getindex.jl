
# have to define several getindex methods to avoid ambiguities with other unit ranges
@propagate_inbounds function Base.getindex(a::AbstractIndex, i::AbstractUnitRange{<:Integer})
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(a::AbstractIndex, i::Integer)
    return _getindex(a, to_index(a, i))
end
@propagate_inbounds function Base.getindex(a::AbstractIndex, i)
    return _getindex(a, to_index(a, i))
end

_getindex(idx::AbstractIndex, i::AbstractVector) = _maybe_index(idx, @inbounds(values(idx)[i]), i)
_getindex(idx::AbstractIndex, i) = @inbounds(values(idx)[i])

function _maybe_index(idx::Index{name}, vs::AbstractUnitRange{<:Integer}, i) where {name}
    return Index{name}(@inbounds(keys(idx)[i]), vs, UnkownUnique, LengthChecked)
end
function _maybe_index(idx::SimpleIndex{name}, vs::AbstractUnitRange{<:Integer}, i) where {name}
    return SimpleIndex{name}(vs)
end
# getindex of values promotes to a vector that can't be an index
_maybe_index(idx::Index{name}, vs::AbstractVector, i) where {name} = vs
_maybe_index(idx::SimpleIndex{name}, vs::AbstractVector, i) where {name} = vs

