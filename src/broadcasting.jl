"""
    BroadcastIndexStyle{S}
"""
struct BroadcastIndexStyle{S <: BroadcastStyle} <: AbstractArrayStyle{Any} end
BroadcastIndexStyle(::S) where {S} = BroadcastIndexStyle{S}()
BroadcastIndexStyle(::S, ::Val{N}) where {S,N} = BroadcastIndexStyle(S(Val(N)))
BroadcastIndexStyle(::Val{N}) where N = BroadcastIndexStyle{DefaultArrayStyle{N}}()

function BroadcastIndexStyle(a::BroadcastStyle, b::BroadcastStyle)
    inner_style = BroadcastStyle(a, b)

    # if the inner_style is Unknown then so is the outer-style
    if inner_style isa Unknown
        return Unknown()
    else
        return BroadcastIndexStyle(inner_style)
    end
end

function Base.BroadcastStyle(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs}
    inner_style = typeof(BroadcastStyle(Vs))
    return BroadcastIndexStyle{inner_style}()
end


Base.BroadcastStyle(::BroadcastIndexStyle{A}, ::BroadcastIndexStyle{B}) where {A, B} = (A(), B())
Base.BroadcastStyle(::BroadcastIndexStyle{A}, b::B) where {A, B} = BroadcastIndexStyle(A(), b)
Base.BroadcastStyle(a::A, ::BroadcastIndexStyle{B}) where {A, B} = BroadcastIndexStyle(a, B())
Base.BroadcastStyle(::BroadcastIndexStyle{A}, b::DefaultArrayStyle) where {A} = BroadcastIndexStyle(A(), b)
Base.BroadcastStyle(a::AbstractArrayStyle{M}, ::BroadcastIndexStyle{B}) where {B,M} = BroadcastIndexStyle(a, B())

function Broadcast.copy(bc::Broadcasted{BroadcastIndexStyle{S}}) where S
    inner_bc = unwrap_broadcasted(bc)
    data = copy(inner_bc)
    return asindex(data)
end



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

function Base.BroadcastStyle(::Type{<:IndicesArray{T,N,Ax,A}}) where {T,N,Ax,A}
    inner_style = typeof(BroadcastStyle(A))
    return IndicesArrayStyle{inner_style}()
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
unwrap_broadcasted(bc::Broadcasted{IndicesArrayStyle{S}}) where S = Broadcasted{S}(bc.f, map(unwrap_broadcasted, bc.args))
unwrap_broadcasted(bc::Broadcasted{BroadcastIndexStyle{S}}) where S = Broadcasted{S}(bc.f, map(unwrap_broadcasted, bc.args))
unwrap_broadcasted(a::AbstractIndicesArray) = parent(a)
#unwrap_broadcasted(a::AbstractIndex) = parent(a)
unwrap_broadcasted(x) = x

# We need to implement copy because if the wrapper array type does not support setindex
# then the `similar` based default method will not work
function Broadcast.copy(bc::Broadcasted{IndicesArrayStyle{S}}) where S
    return IndicesArray(copy(unwrap_broadcasted(bc)), combine_axes(bc))
end
# TODO: copyto! for broadcasting

# TODO
@inline function combine_axes(A::AbstractIndicesArray, B::AbstractIndicesArray, C...)
    broadcast_shape(combine_axes(axes(A), axes(B)), C...)
end

@inline function combine_axes(A::AbstractArray, B::AbstractIndicesArray, C...)
    broadcast_shape(combine_axes(axes(A), axes(B)), C...)
end

@inline function combine_axes(A::AbstractIndicesArray, B::AbstractArray, C...)
    broadcast_shape(combine_axes(axes(A), axes(B)), C...)
end

combine_axes(A::AbstractIndicesArray, B::AbstractIndicesArray) = _combine_axes(axes(A), axes(B))
combine_axes(A::AbstractIndicesArray, B::AbstractArray) = _combine_axes(axes(A), axes(B))
combine_axes(A::AbstractArray, B::AbstractIndicesArray) = _combine_axes(axes(A), axes(B))
combine_axes(A::AbstractIndicesArray) = axes(A)

_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{Any,Vararg{Any}}) = (combine(first(a), first(b)), _combine_axes(tail(a), tail(b))...)
_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{}) = a
_combine_axes(a::Tuple{}, b::Tuple{Any,Vararg{Any}}) = b
_combine_axes(a::Tuple{}, b::Tuple{}) = ()

function combine(a::StaticKeys{AKeys}, b::StaticKeys{BKeys}) where {AKeys,BKeys}
    StaticKeys(merge(AKeys,BKeys))
end

combine(a, b) = asindex(combine_keys(keys(a), keys(b)), IndexingStyle(a, b), combine_names(a, b))

#=
combine(a::OneToIndex, b::OneToIndex) = OneToIndex(union(keys(a), keys(b)))

combine(a::AbstractIndex, b::AbstractIndex) = NamedIndex{combine_names(a, b)}(unname(a), unname(b))

combine(a::NamedIndex, b::AbstractIndex) = NamedIndex{dimnames(a)}(unname(a), b)

function combine(a::AbstractIndex, b::NamedIndex)
    NamedIndex{dimnames(b)}(a, unname(b))
end



#combine(a::AxisIndex, b::AxisIndex) = OneToIndex(union(keys(a), keys(b)))
=#
