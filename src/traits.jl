
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


