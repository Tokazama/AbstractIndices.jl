"""
    IndicesArrayStyle{S}

This is a `BroadcastStyle` for IndicesArray's It preserves the dimension
names. `S` should be the `BroadcastStyle` of the wrapped type.
"""
struct IndicesArrayStyle{S <: BroadcastStyle} <: AbstractArrayStyle{Any} end
IndicesArrayStyle(::S) where {S} = IndicesArrayStyle{S}()
IndicesArrayStyle(::S, ::Val{N}) where {S,N} = IndicesArrayStyle(S(Val(N)))
IndicesArrayStyle(::Val{N}) where N = IndicesArrayStyle{DefaultArrayStyle{N}}()
function IndicesArrayStyle(a::BroadcastStyle, b::BroadcastStyle)
    inner_style = BroadcastStyle(a, b)

    # if the inner_style is Unknown then so is the outer-style
    if inner_style isa Unknown
        return Unknown()
    else
        return IndicesArrayStyle(inner_style)
    end
end

function Base.BroadcastStyle(::Type{T}) where {T<:IndicesArray}
    return IndicesArrayStyle{typeof(BroadcastStyle(parent_type(T)))}()
end


Base.BroadcastStyle(::IndicesArrayStyle{A}, ::IndicesArrayStyle{B}) where {A, B} = IndicesArrayStyle(A(), B())
Base.BroadcastStyle(::IndicesArrayStyle{A}, b::B) where {A, B} = IndicesArrayStyle(A(), b)
Base.BroadcastStyle(a::A, ::IndicesArrayStyle{B}) where {A, B} = IndicesArrayStyle(a, B())
Base.BroadcastStyle(::IndicesArrayStyle{A}, b::DefaultArrayStyle) where {A} = IndicesArrayStyle(A(), b)
Base.BroadcastStyle(a::AbstractArrayStyle{M}, ::IndicesArrayStyle{B}) where {B,M} = IndicesArrayStyle(a, B())

"""
    unwrap_broadcasted

Recursively unwraps `IndicesArray`s and `IndicesArrayStyle`s.
replacing the `IndicesArray`s with the wrapped array,
and `IndicesArrayStyle` with the wrapped `BroadcastStyle`.
"""
function unwrap_broadcasted(bc::Broadcasted{IndicesArrayStyle{S}}) where S
    return Broadcasted{S}(bc.f, map(unwrap_broadcasted, bc.args))
end
#unwrap_broadcasted(bc::Broadcasted{BroadcastIndexStyle{S}}) where S = Broadcasted{S}(bc.f, map(unwrap_broadcasted, bc.args))
unwrap_broadcasted(a::IndicesArray) = parent(a)
#unwrap_broadcasted(a::AbstractIndex) = parent(a)
unwrap_broadcasted(x) = x

# We need to implement copy because if the wrapper array type does not support setindex
# then the `similar` based default method will not work
# TODO: need to make this flexible to other IndicesArrays types
function Broadcast.copy(bc::Broadcasted{IndicesArrayStyle{S}}) where S
    data = unwrap_broadcasted(bc)
    return rebuild(IArray, copy(data), combine_axes(bc.args...))
end
# TODO: copyto! for broadcasting

# TODO
@inline function Broadcast.combine_axes(A::IndicesArray, B::IndicesArray, C...)
    return combine_axes(combine_axes(axes(A), axes(B)), C...)
end

@inline function Broadcast.combine_axes(A::AbstractArray, B::IndicesArray, C...)
    return combine_axes(combine_axes(axes(A), axes(B)), C...)
end

@inline function Broadcast.combine_axes(A::IndicesArray, B::AbstractArray, C...)
    return combine_axes(combine_axes(axes(A), axes(B)), C...)
end

Broadcast.combine_axes(A::IndicesArray, B::IndicesArray) = _combine_axes(indices(A), indices(B))
Broadcast.combine_axes(A::IndicesArray, B::AbstractArray) = _combine_axes(indices(A), indices(B))
Broadcast.combine_axes(A::AbstractArray, B::IndicesArray) = _combine_axes(indices(A), indices(B))
Broadcast.combine_axes(A::IndicesArray) = indices(A)

_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{Any,Vararg{Any}}) = combine_indices(a, b)
#    (combine_indices(first(a), first(b))..., _combine_axes(tail(a), tail(b))...)
#end
_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{}) = a
_combine_axes(a::Tuple{}, b::Tuple{Any,Vararg{Any}}) = b
_combine_axes(a::Tuple{}, b::Tuple{}) = ()

function Broadcast.combine_axes(
    A::Tuple{<:AbstractIndex, Vararg{Any}},
    B::Tuple{<:AbstractIndex, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(
    A::Tuple{<:AbstractIndex, Vararg{Any}},
    B::Tuple{Any, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(
    A::Tuple{Any, Vararg{Any}},
    B::Tuple{<:AbstractIndex, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(A::Tuple{}, B::Tuple{<:AbstractIndex, Vararg{Any}})
    return (combine_indices(first(B))..., combine_axes(A, tail(B))...)
end

function Broadcast.combine_axes(A::Tuple{<:AbstractIndex, Vararg{Any}}, B::Tuple{})
    return (combine_indices(first(A))..., combine_axes(tail(A), B)...)
end
