
#function Base.checkbounds() end

function Base.checkindex(::Type{Bool}, idx::AbstractIndex, i)
    return _checkindex(index_by(idx, i), idx, i)
end
function Base.checkindex(::Type{Bool}, idx::AbstractIndex, i::AbstractVector)
    return _checkindex(index_by(idx, i), idx, i)
end
function Base.checkindex(::Type{Bool}, idx::AbstractIndex, i::AbstractRange)
    return _checkindex(index_by(idx, i), idx, i)
end
function Base.checkindex(::Type{Bool}, idx::AbstractIndex, i::Real)
    return _checkindex(index_by(idx, i), idx, i)
end

_checkindex(::ByKeyTrait, idx, i) = !isnothing(find_first(==(i), keys(idx)))
function _checkindex(::ByKeyTrait, idx, i::AbstractVector)
    for ii in i
        ii in keys(idx) || return false
    end
    return true
end
_checkindex(::ByValueTrait, idx, i) = checkindex(Bool, values(idx), i)
#=
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
=#
