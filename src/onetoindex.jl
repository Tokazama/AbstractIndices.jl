"""
    OneToIndex

An `AbstractIndex` subtype that maps directl to a `OneTo` range.
"""
struct OneToIndex{T,A} <: AbstractIndex{T,Int,A,OneTo}
    axis::A

    function OneToIndex{T,A}(axis::A) where {T,A<:AbstractVector{T}}
        allunique(axis) || error("Not all elements in axis were unique.")
        typeof(axes(axis, 1)) <: OneTo || error("OneToIndex requires an axis with a OneTo index.")
        new{T,A}(axis)
    end
end

OneToIndex(axis::AbstractVector{T}) where {T} = OneToIndex{T,typeof(axis)}(axis)

to_index(x::OneToIndex) = OneTo(length(x))
to_index(x::OneToIndex, i::Int) = i
to_axis(x::OneToIndex) = x.axis