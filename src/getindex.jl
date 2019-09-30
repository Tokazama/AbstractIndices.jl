Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::Int) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    getindex(values(a), findkeys(keys(a), i))
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::K) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    getindex(values(a), findkeys(keys(a), i))
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::AbstractVector{Int}) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), findkeys(keys(a), i)), a)
end

Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{K}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), findkeys(keys(a), i)), a)
end

# this is necessary to avoid ambiguities in base
Base.@propagate_inbounds function getindex(a::AbstractIndex{Int,V,Ks,Vs}, i::AbstractUnitRange{Int}) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}
    asindex(getindex(keys(a), findkeys(keys(a), i)), a)
end

for (I) in (Int,CartesianIndex{1})
    @eval begin
        Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::$I) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            getindex(values(a), i)
        end

        Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, i::AbstractVector{$I}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            asindex(getindex(keys(a), i), a)
        end
    end
end

function getindex(A::AbstractArray{T,N}, i::Vararg{AbstractIndex,N}) where {T,N}
    getindex(A, to_indices(A, i))
end

Base.Slice(x::AbstractIndex) = Base.Slice(values(x))

function Base.getindex(a::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V}
    @boundscheck checkindex(Bool, a, i)
    return values(i)
end

