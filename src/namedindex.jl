NamedIndex{name}(ni::TupOrVec) where {name} = NamedIndex{name}(ni, axes(ni, 1))
NamedIndex{name}(ks::TupOrVec, vs::TupOrVec) where {name} = NamedIndex{name}(asindex(ks, vs))
function NamedIndex{name}(a::AbstractIndex{K,V,Ks,Vs}) where {name,K,V,Ks,Vs}
    NamedIndex{name,K,V,Ks,Vs,typeof(a)}(a)
end

NamedIndex(ks::NamedIndex{name,K,V,Ks,Vs,I}, vs::I) where {name,K,V,Ks,Vs,I<:AbstractIndex} = ks
NamedIndex{name}(ks::NamedIndex{name,K,V,Ks,Vs,I}, vs::I) where {name,K,V,Ks,Vs,I<:AbstractIndex} = ks
NamedIndex{name}(ks::NamedIndex{name,K,V,Ks,Vs,I}) where {name,K,V,Ks,Vs,I<:AbstractIndex} = ks

NamedIndex(ks::NamedIndex{name,K,V ,Ks,OneTo{V },<:AbstractIndex{K,V ,Ks,OneTo{V }}}, vs::OneTo{V }) where {name,K,V,Ks,Vs} = ks
NamedIndex(ks::NamedIndex{name,K,V1,Ks,OneTo{V1},<:AbstractIndex{K,V1,Ks,OneTo{V1}}}, vs::OneTo{V2}) where {name,K,V1,V2,Ks,Vs} = NamedIndex{name}(unname(ks), vs)

#=
function NamedIndex(
    ks::NamedIndex{name,K,V,Ks,Vs,I},
    vs::AbstractIndex
   ) where {name,K,V,Ks,Vs,I<:AbstractIndex}
    return NamedIndex{name}(asindex(unname(ks), vs))
end

function NamedIndex{name}(ni::AbstractIndex{K,V,Ks,Vs}) where {name,K,V,Ks,Vs}
    NamedIndex{name,K,V,Ks,Vs,typeof(ni)}(ni)
end

NamedIndex{name}(ni::NamedIndex{name}) where {name} = ni
=#
#IndexingStyle(::Type{<:NamedIndex{name,K,V,Ks,Vs,I}}) where {name,K,V,Ks,Vs,I} = IndexingStyle(I)

unname(ni::NamedIndex) = ni.index
keys(ni::NamedIndex) = keys(unname(ni))
values(ni::NamedIndex) = values(unname(ni))
dimnames(::NamedIndex{name}) where {name} = name

function Base.similar(ni::NamedIndex{name,K,V}, vs::Type=V) where {name,K,V}
    NamedIndex{name}(similar(ni.index, V))
end
Base.allunique(ni::NamedIndex) = allunique(ni.index)

