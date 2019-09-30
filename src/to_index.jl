to_index(a::AbstractIndex{K},   i::Colon) where {K}               = values(a)
to_index(a::AbstractIndex{K},   i::K) where {K}                   = getindex(values(a), findkeys(keys(a), i))
to_index(a::AbstractIndex{K},   i::Int) where {K}                 = getindex(values(a), i)
to_index(a::AbstractIndex{Int}, i::Int)                           = getindex(values(a), findkeys(keys(a), i))
to_index(a::AbstractIndex{K},   i::CartesianIndex{1}) where{K}    = getindex(values(a), i)

to_index(a::AbstractIndex{K},   i::AbstractVector{K}) where {K}   = getindex(values(a), findkeys(keys(a), i))
to_index(a::AbstractIndex{K},   i::AbstractVector{Int}) where {K} = getindex(values(a), i)
to_index(a::AbstractIndex{Int}, i::AbstractVector{Int})           = getindex(values(a), findkeys(keys(a), i))
to_index(a::AbstractIndex{K},   i::AbstractVector{CartesianIndex{1}}) where {K} = getindex(values(a), inds)

to_index(a::AbstractPosition) = values(a)
to_index(a::AbstractVector, i::AbstractPosition) = values(i)

function to_index(a::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V}
    if a == parent(i)
        return values(i)
    else
        # TODO don't know if this is the best outcome but should be rare
        return to_index(a, values(i))
    end
end


#to_index(a::AbstractVector, i::AbstractIndex) = getindex(a, values(i))

