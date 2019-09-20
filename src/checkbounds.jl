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
    checkindex(Bool, x, first(i.I))
end

checkindex(::Type{Bool}, x::AbstractIndex{K,V}, ::Colon) where {K,V} = true

