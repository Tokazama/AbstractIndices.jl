"""
    IndexingStyle

Indicates the reference frame for indexing.
"""
abstract type IndexingStyle end


"""
    IndexBaseOne

Indicates that an index has indexing starting at one. Default indexing style.
"""
struct IndexBaseOne <: IndexingStyle end

const IdxOne = IndexBaseOne()

IndexingStyle(::T) where {T} = IndexingStyle(T)
IndexingStyle(::Type{T}) where {T} = IdxOne

"""
    IndexBaseOffset

Indicates that an index has indexing starting at an offset.
"""
struct IndexBaseOffset{F} <: IndexingStyle end

offset(::T) where {T} = offset(T)
offset(::Type{IndexBaseOffset{F}}) where {F} = F


Base.has_offset_axes(a::IndexBaseOffset) = true

Base.has_offset_axes(a::IndexBaseOne) = true


IndexingStyle(a::A, b::B) where {A,B} = IndexingStyle(IndexingStyle(A), IndexingStyle(B))
IndexingStyle(::IndexingStyle, ::IndexingStyle) = IdxOne
IndexingStyle(::IndexBaseOne, ::IndexingStyle) = IdxOne
IndexingStyle(::IndexBaseOne, ::IndexBaseOne) = IdxOne
IndexingStyle(::IndexingStyle, ::IndexBaseOne) = IdxOne
IndexingStyle(::IndexBaseOne, ::IndexBaseOffset) = IdxOne
IndexingStyle(::IndexBaseOffset, ::IndexBaseOne) = IdxOne
# TODO: default to first provided offset but may not be the best
IndexingStyle(i1::IndexBaseOffset{I1}, i2::IndexBaseOffset{I2}) where {I1,I2} = i1
IndexingStyle(i1::IndexBaseOffset{I}, i2::IndexBaseOffset{I}) where {I} = i1


