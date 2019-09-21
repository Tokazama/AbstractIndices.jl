checkbounds(::Type{Bool}, x::AbstractIndex, i) = checkindex(Bool, x, i)

function checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::K) where {K,V}
    firstindex(x) <= i <= lastindex(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::Int) where {K,V}
    firstindex(values(x)) <= i <= lastindex(values(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,V}, i::Int) where {V}
    i in keys(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::AbstractVector{Int}) where {K,V}
    checkindex(Bool, values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::AbstractVector{K}) where {K,V}
    issubset(i, keys(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,V}, i::AbstractVector{Int}) where {V}
    issubset(i, keys(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex, i::CartesianIndex{1})
    checkindex(Bool, values(x), first(i.I))
end

function checkindex(::Type{Bool}, x::AbstractIndex, i::CartesianIndices{1})
    return checkindex(Bool, x, first(i)) & checkindex(Bool, x, last(i))
end

checkindex(::Type{Bool}, x::AbstractIndex{K,V}, ::Colon) where {K,V} = true

function checkindex(::Type{Bool}, x::TupOrVec{K}, i::AbstractPosition{K}) where {K}
    isnothing(findfirst(isequal(i), keys(i)))
end

checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V} = haskey(x, keys(i))

Base.haskey(x::AbstractIndex{K,V}, i::K) where {K,V} = in(i, keys(x))

 

