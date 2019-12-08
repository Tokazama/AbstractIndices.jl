
"""
    axes2size
"""
axes2size(x::AbstractArray) = axes2size(axes(x))
axes2size(x::Tuple) = length.(x)

"""
    axes2length
"""
axes2length(x::AbstractArray) = axes2length(axes(x))
axes2length(x::Tuple{Any,Vararg{Any}}) = length(first(x)) * axes2length(tail(x))
axes2length(x::Tuple{Any}) = length(first(x))

_prod(x::Tuple{Integer,Vararg}) = first(x) * _prod(tail(x))
_prod(x::Tuple{Colon,Vararg}) = _prod(tail(x))
_prod(x::Tuple{Integer}) = first(x)
_prod(x::Tuple{Colon}) = 1

