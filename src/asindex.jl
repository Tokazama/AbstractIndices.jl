"""
    asindex(keys)
    asindex(keys, values)
    asindex(keys, name)
    asindex(keys, values, name)

Chooses the most appropriate index type for an keys and index set. Including
a `Symbol` for the name argument results in a `NamedIndex`.
"""
asindex(a::AbstractIndex) = a
asindex(keys::TupOrVec) = asindex(keys, axes(keys, 1))
asindex(ks::Tuple{Vararg{Symbol}}) = StaticKeys(ks)
asindex(ks::Tuple{Vararg{Symbol}}, ::OneTo) = StaticKeys(ks)

# the index inside of `vs` is exactly the same as ks

# NamedIndex - we want it to be the top level wrapper for all other indexes
asindex(a::AbstractIndex,          name::Nothing) = a
asindex(a::TupOrVec,               name::Nothing) = asindex(a)
asindex(a::TupOrVec,               name::Symbol ) = NamedIndex{name}(asindex(a))
asindex(a::AbstractIndex,          name::Symbol ) = NamedIndex{name}(a)
function asindex(a::NamedIndex{n}, name::Symbol) where {n}
    if n === name
        return a
    else
        return NamedIndex{name}(unname(a))
    end
end

asindex(ks::A, vs::A) where {A<:AbstractIndex} = ks

asindex(ks::TupOrVec, vs::TupOrVec, name::Nothing) = asindex(ks, vs)
asindex(ks::TupOrVec, vs::TupOrVec, name::Symbol) = asindex(asindex(ks, vs), name)

# Bypass as many parameter checks and reconstructions as possible here
asindex(ks::AbstractVector{K},        vs::OneTo{V}) where {K,V} = OneToIndex(ks, vs)


asindex(ks::LinearIndices{1}, vs::TupOrVec) = asindex(first(ks.indices), vs)
asindex(ks::TupOrVec, vs::LinearIndices{1}) = asindex(ks, first(vs.indices))

#asindex(ks::LinearIndices{1}, vs::OneTo, name) = asindex(first(ks.indices), vs)
asindex(ks::LinearIndices{1}, vs::OneTo) = asindex(first(ks.indices), vs)

function asindex(ks::AbstractIndex{K,V1,Ks,OneTo{V1}}, vs::OneTo{V2}) where {K,V1,V2,Ks}
    OneToIndex{K,V2,Ks}(keys(ks), CheckedUniqueTrue)
end
asindex(ks::AbstractIndex{K,V,Ks,OneTo{V}}, vs::OneTo{V}) where {K,V,Ks} = ks
asindex(ks::TupOrVec, vs::AbstractUnitRange) = AxisIndex(ks, vs)

@inline function asindex(ks::K, vs::V) where {K<:AbstractIndex,V<:TupOrVec}
    if have_same_values(vs)
        return ks
    else
        if hasdimnames(ks)
            return NamedIndex{dimnames(ks)}(asindex(keys(ks), vs))
        else
            return asindex(keys(ks), vs)
        end
    end
end

@inline function asindex(ks::K, vs::V) where {K<:TupOrVec,V<:AbstractIndex}
    if hasdimnames(vs)
        return NamedIndex{dimnames(ks)}(asindex(keys(ks), values(vs)))
    else
        return asindex(keys(ks), values(vs))
    end
end
 
# 2x AbstractIndex
@inline function asindex(ks::K, vs::V) where {K<:AbstractIndex,V<:AbstractIndex}
    if have_same_values(ks, vs)
        if hasdimnames(vs)
            if hasdimnames(ks)
                return ks
            else
                return NamedIndex{dimnames(vs)}(ks)
            end
        else
            return ks
        end
    else
        return asindex(ks, values(vs))
    end
end
