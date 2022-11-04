
struct OpaqueIndex{T<:IndexPrimitiveType} <: AbstractVector{T}
    data::Tuple{Vararg{T}}

    OpaqueIndex{T}(@nospecialize(x::Tuple)) where {T} = new{T}(x)
    OpaqueIndex(@nospecialize(x::Tuple)) = new{eltype(x)}(x)
end

Base.first(x::OpaqueIndex) = getfirst(_tuple(x), 1)
Base.last(x::OpaqueIndex) = getfirst(_tuple(x), _length(x))

Base.iterate(x::OpaqueIndex) = _length(x) === 0 ? nothing : (_get(x, 1), 2)
Base.iterate(x::OpaqueIndex, s::Int) = s > _length(x) ? nothing : (_get(x, s), s + 1)

