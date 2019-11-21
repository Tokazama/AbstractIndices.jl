function Base.broadcasted(das::DefaultArrayStyle{1}, f::typeof(+), r1::AbstractIndex, r2::AbstractUnitRange)
    return broadcasted(das, f, promote(r1, r2)...)
end
function Base.broadcasted(das::DefaultArrayStyle{1}, f::typeof(+), r1::AbstractUnitRange, r2::AbstractIndex)
    return broadcasted(das, f, promote(r1, r2)...)
end
function Base.broadcasted(das::DefaultArrayStyle{1}, f::typeof(+), r1::AbstractIndex, r2::AbstractIndex)
    if same_type(r1, r2)
        return similar_type(r1)(combine_keys(r1, r2), +(values(r1), values(r2)))
    else
        return broadcasted(das, f, promote(r1, r2)...)
    end
end


