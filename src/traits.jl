#=
    IndexLike

There are two components to any index, the keys and the values. These differ
from dictionaries in that the values must always be a subtype of
`AbstractUnitRange`. This facilitates a number of convenient traits and
assumptions concerning and index's behavior. When this behavior is overly
restrictive it makes sense use an index as component of some other object.
For example, a dictionary could potentially utilize the keys of an index
to map to the location of the dictionaries values.

# Keys

The only restriction to a collection of keys is that they all be unique to the
other keys in the same collection. This behavior is similar to what's seen if
you use `Set` or the keys of most `AbstractDict` subtypes. Keys of an index
allow the same customization and optimization that is commonly seen throughout
Julia via variety of dynamic, static, or immutable subtypes of `AbstractVector`.
Therefore, the only unique quality of keys for an index is the dichotomy offered
by the `ContinuousTrait` or `DiscreteTrait`.

* Continuous keys : Continuous keys imply an order the inherit to it's type.
  Therefore, all keys that are continuous are assumed to be some sort of range.
  This has the potential to speed up many operations but limits the ability to
  use keys with semantic meaning.
* Discrete keys: All vectors that are not ranges are assumed to be discrete,
  offering increased flexibility at the cost of performance.

It's worth noting that given some customization may help convert a system that
uses discrete keys into one of continuous keys. For example, using the
`Unitful.jl` package can facilitate the use of semantic units of measurement
as a well defined range.


# Values
=#


"""
    permute_indices(a, perms)

Returns axes of `a` in the order of `perms`.
"""
permute_indices(a, perms) = permute_indices(axes(a), perms)
function permute_indices(a::NTuple{N}, perms::NTuple{N,Int}) where {N}
    return map(i -> getfield(a, i), perms)
end

matmul_indices(a, b) = _multiply_indices(axes(a), axes(b))
_multiply_indices(a::Tuple{Any}, b::Tuple{Any,Any}) = (first(a), last(b))
_multiply_indices(a::Tuple{Any,Any}, b::Tuple{Any,Any}) = (first(a), last(b))
_multiply_indices(a::Tuple{Any,Any}, b::Tuple{Any}) = (first(a),)

function covcor_indices(a, dims::Integer)
    if d == 1
        return (axes(a, 2), axes(a, 2))
    elseif d == 2
        return (axes(a, 1), axes(a, 1))
    end
end

inv_indices(a) = (axes(a, 2), axes(a, 1))

"""
    reduce_axis(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduce_axis(a::AbstractVector{T}) where {T} = one(T)

"""
    reduce_indices(a; dims)
"""
reduce_indices(a; dims) = reduce_indices(a, dims)
reduce_indices(a, dims) = _reduce_indices(axes(a), to_dims(a, dims))
_reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduce_indices(axs, (dims,))
function _reduce_indices(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i->ifelse(in(i, dims), reduce_axis(axs[i]), axs[i]), 1:D))
end

"""
    reshape_indices(a, dims)
    reshape_indices(a, dims...)
"""
reshape_indices(a, dims::Int...) = reshape_indices(a, Tuple(dims))
reshape_indices(a, dims::Tuple) = _reshape_indices(axes(a), dims)
function _reshape_indices(axs::Tuple{Any,Vararg}, dims::Tuple{Int,Vararg})
    (_to_shape(first(axs), first(dims)), _reshape_indices(tail(axs), tail(dims))...)
end
_reshape_indices(axs::Tuple{}, dims::Tuple{}) = ()

function _to_shape(axs, i::Int)
    if length(axs) == i
        return copy(axs)
    elseif length(axs) > i
        return shrink_last(axs, i)
    elseif length(axs) < i
        return grow_last(axs, i)
    end
end
