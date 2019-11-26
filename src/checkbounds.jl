

#function Base.checkbounds() end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::K) where {name,K<:Real}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::K) where {name,K}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,Int}, i::Int) where {name}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,CartesianIndex{1}}, i::CartesianIndex{1}) where {name}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::Int) where {name,K}
    return !isnothing(find_first(==(i), keys(values(indx))))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::CartesianIndex{1}) where {name,K}
    return !isnothing(find_first(==(i), keys(values(indx))))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::AbstractVector{K}) where {name,K}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,CartesianIndex{1}}, i::AbstractVector{CartesianIndex{1}}) where {name}
    return !isnothing(find_first(==(i), keys(indx)))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::AbstractVector{Int}) where {name,K}
    return !isnothing(find_first(==(i), keys(values(indx))))
end

function Base.checkindex(::Type{Bool}, indx::AbstractIndex{name,K}, i::AbstractVector{CartesianIndex{1}}) where {name,K}
    return !isnothing(find_first(==(i), keys(values(indx))))
end

