"""

    asindex(keys[, values])

Chooses the most appropriate index type for an keys and index set.
"""
asindex(keys::TupOrVec{K}) where {K} = asindex(keys, IndexingStyle(keys))

asindex(ks::TupOrVec, vs::TupOrVec) = asindex(ks, IndexingStyle(vs), combine_names(ks, vs))

asindex(ks::AbstractIndex, vs::TupOrVec) = asindex(keys(ks), IndexingStyle(vs), combine_names(ks, vs))

asindex(a::AbstractIndex) = a

asindex(a::AbstractIndex, name::Symbol) = NamedIndex{name}(a)
asindex(a::AbstractIndex, name::Nothing) = a

asindex(ks::TupOrVec, s::IndexingStyle, name::Nothing) = asindex(ks, s)
asindex(ks::TupOrVec, s::IndexingStyle, name::Symbol) = NamedIndex{name}(asindex(ks, s))
