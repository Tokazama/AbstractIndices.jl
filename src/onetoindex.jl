"""
    OneToIndex

An `AbstractIndex` subtype that maps directly to a `OneTo` range. Conversion of
any `AbstractVector
"""
struct OneToIndex{T,A} <: AbstractIndex{T,Int,A,OneTo{Int}}
    axis::A

    function OneToIndex{T,A}(axis::A) where {T,A<:AbstractVector{T}}
        allunique(axis) || error("Not all elements in axis were unique.")
        typeof(axes(axis, 1)) <: OneTo || error("OneToIndex requires an axis with a OneTo index.")
        new{T,A}(axis)
    end
end

OneToIndex(axis::AbstractVector{T}) where {T} = OneToIndex{T,typeof(axis)}(axis)

length(x::OneToIndex) = length(keys(x))

Base.values(x::OneToIndex) = OneTo(length(x))
Base.values(x::OneToIndex, i::Int) = i
Base.keys(x::OneToIndex) = x.axis

function show(io::IO, ::MIME"text/plain", x::OneToIndex{T,<:AbstractRange}) where {T}
    print(io, "OneToIndex($(keys(x)))")
end

