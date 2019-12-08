

"""
    rebuild(x, vals, axs)
"""
rebuild(x, vals, axs) = rebuild(typeof(x), vals, axs)
function rebuild(::Type{T}, vals, axs) where {T<:IndicesArray}
    error("All subtypes of IndicesArray must implement rebuild method.")
end

rebuild(::Type{T}, vals, axs::Tuple{}) where {T<:IArray} = vals
function rebuild(::Type{T}, vals, axs::Tuple)  where {T<:IArray}
    return IArray(vals, axs, AllUnique, LengthChecked)
end


"""
    rebuild_rule(::Type, ::Type)
"""
rebuild_rule(a, b) = rebuild_rule(typeof(a), typeof(b))
rebuild_rule(::Type{A}, ::Type{B}) where {A<:IndicesArray,B<:AbstractArray} = A
rebuild_rule(::Type{A}, ::Type{B}) where {A<:AbstractArray,B<:IndicesArray} = B
rebuild_rule(::Type{A}, ::Type{B}) where {A<:IArray,B<:IArray} = A

function rebuild_rule(::Type{A}, ::Type{B}) where {A<:IndicesArray,B<:IndicesArray}
    T = promote_rule(A, B)
    return T<:Union{} ? promote_rule(B,A) : T
end

