"""
    Index
"""
struct Index{K,Ks,Vs} <: AbstractIndex{K,Int,Ks,Vs}
    _keys::Ks
    _values::Vs

    function Index{K,Ks,Vs}(ks::Ks, vs::Vs, uc::Uniqueness, lc::AbstractLengthCheck) where {K,Ks<:AbstractVector{K},Vs}
        check_index_length(ks, vs, lc)
        check_index_uniqueness(ks, uc)
        return new{K,Ks,Vs}(ks, vs)
    end
end

function Index(ks::AbstractVector, uc::Uniqueness=UnkownUnique)
    if is_static(ks)
        return Index(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Index(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Index(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Index(
    ks::AbstractVector{K},
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K}
    return Index{K,typeof(ks),typeof(vs)}(ks, vs, uc, lc)
end

function Index(
    ks::AbstractIndex,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Index(keys(ks), vs, uc, lc)
end

function Index(
    ks::AbstractVector,
    vs::AbstractIndex{K,Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K}
    return Index(ks, values(vs), uc, lc)
end

Index(idx::Index) = Index(keys(idx), values(idx), AllUnique, LengthChecked)

Base.keys(idx::Index) = getfield(idx, :_keys)

Base.values(idx::Index) = getfield(idx, :_values)

StaticRanges.similar_type(x::Index) = Index

function Base.setproperty!(idx::Index{K,Ks,Vs}, p::Symbol, val) where {K,Ks,Vs}
    if is_dynamic(idx)
        if p === :keys
            if val isa Ks
                if length(val) == length(idx)
                    return setfield!(idx, :_keys, val)
                else
                    error("`val` must be the same length as the provided index.")
                end
            else
                return setproperty!(idx, p, convert(Ks, val))
            end
        elseif p === :values
            if val isa Vs
                if length(val) == length(idx)
                    return setfield!(idx, :_values, val)
                else
                    error("`val` must be the same length as the provided index.")
                end
            else
                return setproperty!(idx, p, convert(Vs, val))
            end
        else
            error("No property named $p.")
        end
    else
        error("The keys and values of an Index must be mutable to use `setproperty!`, got $(typeof(idx)).")
    end
end
