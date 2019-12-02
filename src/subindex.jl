#### SubIndex of Index. Used by SubDataFrame, DataFrameRow, and DataFrameRows

struct SubIndex{I<:AbstractIndex,S<:AbstractVector{Int},T<:AbstractVector{Int}} <: AbstractIndex
    parent::I
    cols::S # columns from idx selected in SubIndex
    remap::T # reverse mapping from cols to their position in the SubIndex
end

SubIndex(parent::AbstractIndex, ::Colon) = parent

Base.copy(x::SubIndex) = Index(_names(x))

@inline parentcols(ind::SubIndex) = ind.cols

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Union{Integer,AbstractVector{<:Integer}}) =
    ind.cols[idx]
Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Bool) =
    throw(ArgumentError("column indexing with Bool is not allowed"))

Base.@propagate_inbounds function parentcols(ind::SubIndex, idx::Symbol)
    parentcol = ind.parent[idx]
    @boundscheck begin
        remap = ind.remap
        remap[parentcol] == 0 && throw(ArgumentError("$idx not found"))
    end
    return parentcol
end

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::AbstractVector{Symbol}) =
    [parentcols(ind, i) for i in idx]

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Regex) =
    [parentcols(ind, i) for i in _names(ind) if occursin(idx, String(i))]

Base.@propagate_inbounds parentcols(ind::SubIndex, ::Colon) = ind.cols

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Not) = parentcols(ind, ind[idx])

function SubIndex(parent::AbstractIndex, cols::AbstractUnitRange{Int})
    l = last(cols)
    f = first(cols)
    if !checkindex(Bool, Base.OneTo(length(parent)), cols)
        throw(BoundsError("invalid columns $cols selected"))
    end
    remap = (1:l) .- f .+ 1
    SubIndex(parent, cols, remap)
end

function SubIndex(parent::AbstractIndex, cols::AbstractVector{Int})
    ncols = length(parent)
    remap = zeros(Int, ncols)
    for (i, col) in enumerate(cols)
        if !(1 <= col <= ncols)
            throw(BoundsError("column index must be greater than zero " *
                              "and not larger than number columns in the parent"))
        end
        if remap[col] != 0
            throw(ArgumentError("duplicate selected column detected"))
        end
        remap[col] = i
    end
    SubIndex(parent, cols, remap)
end

@inline SubIndex(parent::AbstractIndex, cols::ColumnIndex) =
    throw(ArgumentError("cols argument must be a vector (got $cols)"))

Base.@propagate_inbounds SubIndex(parent::AbstractIndex, cols) =
    SubIndex(parent, parent[cols])

Base.length(x::SubIndex) = length(x.cols)
Base.names(x::SubIndex) = copy(_names(x))
_names(x::SubIndex) = view(_names(x.parent), x.cols)

function Base.haskey(x::SubIndex, key::Symbol)
    haskey(x.parent, key) || return false
    pos = x.parent[key]
    remap = x.remap
    checkbounds(Bool, remap, pos) || return false
    remap[pos] > 0
end

Base.haskey(x::SubIndex, key::Integer) = 1 <= key <= length(x)
Base.haskey(x::SubIndex, key::Bool) =
    throw(ArgumentError("invalid key: $key of type Bool"))
Base.keys(x::SubIndex) = names(x)

function Base.getindex(x::SubIndex, idx::Symbol)
    remap = x.remap
    remap[x.parent[idx]]
end

function Base.getindex(x::SubIndex, idx::AbstractVector{Symbol})
    allunique(idx) || throw(ArgumentError("Elements of $idx must be unique"))
    [x[i] for i in idx]
end## SubIndex of Index. Used by SubDataFrame, DataFrameRow, and DataFrameRows

struct SubIndex{I<:AbstractIndex,S<:AbstractVector{Int},T<:AbstractVector{Int}} <: AbstractIndex
    parent::I
    cols::S # columns from idx selected in SubIndex
    remap::T # reverse mapping from cols to their position in the SubIndex
end

SubIndex(parent::AbstractIndex, ::Colon) = parent

Base.copy(x::SubIndex) = Index(_names(x))

@inline parentcols(ind::SubIndex) = ind.cols

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Union{Integer,AbstractVector{<:Integer}}) =
    ind.cols[idx]
Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Bool) =
    throw(ArgumentError("column indexing with Bool is not allowed"))

Base.@propagate_inbounds function parentcols(ind::SubIndex, idx::Symbol)
    parentcol = ind.parent[idx]
    @boundscheck begin
        remap = ind.remap
        remap[parentcol] == 0 && throw(ArgumentError("$idx not found"))
    end
    return parentcol
end

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::AbstractVector{Symbol}) =
    [parentcols(ind, i) for i in idx]

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Regex) =
    [parentcols(ind, i) for i in _names(ind) if occursin(idx, String(i))]

Base.@propagate_inbounds parentcols(ind::SubIndex, ::Colon) = ind.cols

Base.@propagate_inbounds parentcols(ind::SubIndex, idx::Not) = parentcols(ind, ind[idx])

function SubIndex(parent::AbstractIndex, cols::AbstractUnitRange{Int})
    l = last(cols)
    f = first(cols)
    if !checkindex(Bool, Base.OneTo(length(parent)), cols)
        throw(BoundsError("invalid columns $cols selected"))
    end
    remap = (1:l) .- f .+ 1
    SubIndex(parent, cols, remap)
end

function SubIndex(parent::AbstractIndex, cols::AbstractVector{Int})
    ncols = length(parent)
    remap = zeros(Int, ncols)
    for (i, col) in enumerate(cols)
        if !(1 <= col <= ncols)
            throw(BoundsError("column index must be greater than zero " *
                              "and not larger than number columns in the parent"))
        end
        if remap[col] != 0
            throw(ArgumentError("duplicate selected column detected"))
        end
        remap[col] = i
    end
    SubIndex(parent, cols, remap)
end

@inline SubIndex(parent::AbstractIndex, cols::ColumnIndex) =
    throw(ArgumentError("cols argument must be a vector (got $cols)"))

Base.@propagate_inbounds SubIndex(parent::AbstractIndex, cols) =
    SubIndex(parent, parent[cols])

Base.length(x::SubIndex) = length(x.cols)
Base.names(x::SubIndex) = copy(_names(x))
_names(x::SubIndex) = view(_names(x.parent), x.cols)

function Base.haskey(x::SubIndex, key::Symbol)
    haskey(x.parent, key) || return false
    pos = x.parent[key]
    remap = x.remap
    checkbounds(Bool, remap, pos) || return false
    remap[pos] > 0
end

Base.haskey(x::SubIndex, key::Integer) = 1 <= key <= length(x)
Base.haskey(x::SubIndex, key::Bool) =
    throw(ArgumentError("invalid key: $key of type Bool"))
Base.keys(x::SubIndex) = names(x)

function Base.getindex(x::SubIndex, idx::Symbol)
    remap = x.remap
    remap[x.parent[idx]]
end

function Base.getindex(x::SubIndex, idx::AbstractVector{Symbol})
    allunique(idx) || throw(ArgumentError("Elements of $idx must be unique"))
    [x[i] for i in idx]
end
