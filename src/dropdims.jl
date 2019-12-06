@inline Base.dropdims(a::IndicesArray; dims) = _dropdims(a, to_dims(a, dims))
function _dropdims(a, d)
    return IndicesArray(
        dropdims(parent(a); dims=d),
        drop_axes(a, dims=d),
        AllUnique,
        LengthChecked
       )
end
