"""
    NamedIndex

A subtype of `AbstractIndex` with a name.
"""
struct NamedIndex{name,K,V,Ks,Vs,I<:AbstractIndex{K,V,Ks,Vs}} <: AbstractIndex{K,V,Ks,Vs}
    index::I

    function NamedIndex{name,K,V,Ks,Vs,I}(index::I) where {name,K,V,Ks,Vs,I}
        new{name,K,V,Ks,Vs,I}(index)
    end
end

# TODO revisit this constructor. seems a bit odd but might be nice to have
(name::Symbol)(a::AbstractIndex) = NamedIndex{name}(a)

NamedIndex{name}(ni::TupOrVec) where {name} = NamedIndex{name}(asindex(ni))
NamedIndex{name}(ks::TupOrVec, vs::TupOrVec) where {name} = NamedIndex{name}(asindex(ks, vs))

HasDimNames(::Type{<:NamedIndex}) = HDNTrue

function NamedIndex{name}(ni::AbstractIndex{K,V,Ks,Vs}) where {name,K,V,Ks,Vs}
    NamedIndex{name,K,V,Ks,Vs,typeof(ni)}(ni)
end

NamedIndex{name}(ni::NamedIndex{name}) where {name} = ni

IndexingStyle(::Type{<:NamedIndex{name,K,V,Ks,Vs,I}}) where {name,K,V,Ks,Vs,I} = IndexingStyle(I)

unname(ni::NamedIndex) = ni.index
keys(ni::NamedIndex) = keys(unname(ni))
values(ni::NamedIndex) = values(unname(ni))
dimnames(::NamedIndex{name}) where {name} = name

function Base.similar(ni::NamedIndex{name,K,V}, vs::Type=V) where {name,K,V}
    NamedIndex{name}(similar(ni.index, V))
end
Base.allunique(ni::NamedIndex) = allunique(ni.index)
