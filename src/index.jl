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

function Index{K,Ks,Vs}(
    ks::Ks2,
    vs::Vs2,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K,Ks<:AbstractVector{K},Vs,Ks2,Vs2}
    return Index(Ks(ks), Vs(vs), uc, lc)
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
    return Index{K}(ks, vs, uc, lc)
end

function Index{K}(
    ks::Ks,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K,Ks<:AbstractVector{K}}
    return Index{K,Ks}(ks, vs, uc, lc)
end

function Index{K,Ks}(
    ks::Ks,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K,Ks<:AbstractVector{K}}
    return Index{K,Ks,typeof(vs)}(ks, vs, uc, lc)
end

function Index(
    ks::AbstractIndex,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Index(keys(ks), vs, uc, lc)
end

Index{K,Ks,Vs}(idx::Index{K,Ks,Vs}) where {K,Ks,Vs} = copy(idx)

#=
function Index(
    ks::AbstractVector,
    vs::AbstractIndex{K,Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {K}
    return Index(ks, values(vs), uc, lc)
end
=#

Index(idx::Index) = Index(keys(idx), values(idx), AllUnique, LengthChecked)

Base.keys(idx::Index) = getfield(idx, :_keys)

Base.values(idx::Index) = getfield(idx, :_values)

function StaticRanges.similar_type(
    idx::Index,
    ks_type::Type=similar_type(keys(idx)),
    vs_type::Type=similar_type(values(idx))
   )
    return Index{eltype(ks_type),ks_type,vs_type}
end

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


# TODO: is this the best fall back for and AbstractIndex?
AbstractIndex(x) = Index(x)
