checkbounds(::Type{Bool}, x::AbstractIndex, i) = checkindex(Bool, x, i)

function checkindex(::Type{Bool}, x::AbstractIndex{K,V,Ks,Vs}, i::K) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    haskey(x, i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V,Ks,Vs}, i::K) where {K<:Real,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    haskey(x, i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V,Ks,Vs}, i::Int) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    checkindex(Bool, values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,V,Ks,Vs}, i::Int) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    i in keys(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{Int}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    checkindex(Bool, values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{K}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    issubset(i, keys(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,V,Ks,Vs}, i::AbstractVector{Int}) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    issubset(i, keys(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex, i::CartesianIndex{1})
    checkindex(Bool, values(x), first(i.I))
end

function checkindex(::Type{Bool}, x::AbstractIndex, i::CartesianIndices{1})
    return checkindex(Bool, x, first(i)) & checkindex(Bool, x, last(i))
end

checkindex(::Type{Bool}, x::AbstractIndex, ::Colon) = true

function checkindex(::Type{Bool}, x::TupOrVec{K}, i::AbstractPosition{K}) where {K}
    isnothing(findfirst(isequal(i), keys(i)))
end

checkindex(::Type{Bool}, x::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V} = haskey(x, keys(i))

function Base.checkbounds_indices(::Type{Bool}, IA::Tuple{AbstractIndex,Vararg{Any}}, ::Tuple{})
    Base.@_inline_meta
    all(x->length(x)==1, IA)
end

