"""
    Index
"""
struct Index{name,K,V,Ks,Vs} <: AbstractIndex{name,K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function Index{name,K,V,Ks,Vs}(ks::Ks, vs::Vs, uc::Uniqueness, lc::AbstractLengthCheck) where {name,K,V,Ks<:AbstractVector{K},Vs<:AbstractUnitRange{V}}
        check_index_length(ks, vs, lc)
        check_index_uniqueness(ks, uc)
        return new{name,K,V,Ks,Vs}(ks, vs)
    end
end

function Index{name,K,V,Ks,Vs}(
    ks::Ks2,
    vs::Vs2,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks<:AbstractVector{K},Vs<:AbstractUnitRange{V},Ks2,Vs2}
    return Index{name}(Ks(ks), Vs(vs), uc, lc)
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

function Index{name}(
    ks::AbstractVector,
    uc::Uniqueness=UnkownUnique
   ) where {name,K}
    if is_static(ks)
        return Index{name}(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Index{name}(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Index{name}(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Index(
    ks::AbstractVector,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Index{nothing}(ks, vs, uc, lc)
end

function Index{name}(
    ks::AbstractVector{K},
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K}
    return Index{name,K}(ks, vs, uc, lc)
end

function Index{name,K}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks<:AbstractVector{K}}
    return Index{name,K,V,Ks}(ks, vs, uc, lc)
end

function Index{name,K,V,Ks}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks<:AbstractVector{K}}
    return Index{name,K,V,Ks,typeof(vs)}(ks, vs, uc, lc)
end

function Index(
    ks::AbstractIndex,
    vs::AbstractUnitRange,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Index{indnames(ks)}(keys(ks), vs, uc, lc)
end

function Index{name1,K,V,Ks,Vs}(idx::Index) where {name1,name2,K,V,Ks,Vs}
    return Index{}()
end

Index(idx::Index) = Index(keys(idx), values(idx), AllUnique, LengthChecked)

Base.keys(idx::Index) = getfield(idx, :_keys)

Base.values(idx::Index) = getfield(idx, :_values)

function StaticRanges.similar_type(
    idx::Index{name},
    ks_type::Type=keys_type(idx),
    vs_type::Type=values_type(idx)
   ) where {name}
    return Index{name,eltype(ks_type),eltype(vs_type),ks_type,vs_type}
end

function Base.setproperty!(idx::Index{name,K,V,Ks,Vs}, p::Symbol, val) where {name,K,V,Ks,Vs}
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
