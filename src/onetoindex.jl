"""
    OneToIndex

An `AbstractIndex` subtype that maps directl to a `OneTo` range.
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

length(x::OneToIndex) = length(to_axis(x))

to_index(x::OneToIndex) = OneTo(length(x))
to_index(x::OneToIndex, i::Int) = i
to_axis(x::OneToIndex) = x.axis

function show(io::IO, ::MIME"text/plain", x::OneToIndex{T,<:AbstractRange}) where {T}
    print(io, "OneToIndex($(to_axis(x)))")
end

