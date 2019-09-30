Base.@propagate_inbounds function setindex!(
    a::AbstractIndex{Int,V,Ks,Vs},
    val::Any,
    i::Int
   ) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}

    setindex!(values(a), val, findkeys(keys(a), i))
end

Base.@propagate_inbounds function setindex!(
    a::AbstractIndex{K,V,Ks,Vs},
    val::Any,
    i::K
   ) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}

    setindex!(values(a), val, findkeys(keys(a), i))
end

Base.@propagate_inbounds function setindex!(
    a::AbstractIndex{Int,V,Ks,Vs},
    val::AbstractVector,
    i::AbstractVector{Int}
   ) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}

    setindex!(values(a), val, findkeys(keys(a), i))
end

Base.@propagate_inbounds function setindex!(
    a::AbstractIndex{K,V,Ks,Vs},
    val::AbstractVector,
    i::AbstractVector{K}
   ) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}

    setindex!(values(a), val, findkeys(keys(a), i))
end

# this is necessary to avoid ambiguities in base
Base.@propagate_inbounds function getindex(
    a::AbstractIndex{Int,V,Ks,Vs},
    val::AbstractVector,
    i::AbstractUnitRange{Int}
   ) where {V,Ks<:TupOrVec{Int},Vs<:AbstractUnitRange{V}}

    setindex!(values(a), val, findkeys(keys(a), i))
end

for (I) in (Int,CartesianIndex{1})
    @eval begin
        Base.@propagate_inbounds function setindex!(a::AbstractIndex{K,V,Ks,Vs}, val, i::$I) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            setindex!(values(a), val, i)
        end

        Base.@propagate_inbounds function getindex(a::AbstractIndex{K,V,Ks,Vs}, val, i::AbstractVector{$I}) where {K,V,Ks<:TupOrVec{K},Vs<:AbstractUnitRange{V}}
            setindex!(values(a), val, i)
        end
    end
end

function setindex!(A::AbstractArray{T,N}, val, i::Vararg{AbstractIndex,N}) where {T,N}
    setindex!(A, to_indices(A, i))
end

#=
function Base.getindex(a::AbstractIndex{K,V}, i::AbstractPosition{K,V}) where {K,V}
    @boundscheck checkindex(Bool, a, i)
    return values(i)
end
=#
