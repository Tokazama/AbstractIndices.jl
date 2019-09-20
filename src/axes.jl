# Details: These are functions that I've found useful. They are unlikely to
# have been optimized for performance.

const NamedAxes{N} = Tuple{Vararg{<:AbstractIndex,N}}
NamedAxes(; kwargs...) = Tuple([NamedIndex{k}(v) for (k,v) in kwargs])

dimnames(axs::NamedAxes) = dimnames.(axs)
unname(axs::NamedAxes) = unname.(axs)


"""
    findaxes(f, x)

Returns a tuple of indices for which the axes of `x` are true under `f`. If `x`
has named dimensions this is a tuple of symbols. Otherwise, a tuple of integers
is returned. If all axes return false under the conditions of `f` then
`nothing` is returned.
"""
findaxes(f, x) = _catch_empty(_findaxes(f, axes(x), 1))
function _findaxes(f, t::Tuple, cnt::Int)
    if f(first(t))
        return (cnt, _findaxes(f, tail(t), cnt+1)...)
    else
        return _findaxes(f, tail(t), cnt+1)
    end
end
_findaxes(f, ::Tuple{}, ::Int) = ()


"""
    filteraxes(f, a)

Return the axes of `a`, removing those for which `f` is false. The function `f`
is passed one argument.
"""
filteraxes(f, x) = _catch_empty(_filteraxes(f, axes(x)))
function _filteraxes(f, t::Tuple)
    if f(first(t))
        return (first(t), _filteraxes(f, tail(t))...)
    else
        return _filteraxes(f, tail(t))
    end
end
_filteraxes(f, ::Tuple{}) = ()

"""
    mapaxes(f, a)

map function `f` over the axes of `a`.
"""
mapaxes(f, a) = map(f, axes(a))

"""
    dropaxes(a, dims)

Returns tuple of axes that don't include `dims`.
"""
function dropaxes()
end


"""
    permuteaxes(a, perms)

Returns axes of `a` in the order of `perms`.
"""
permuteaxes(a, perms) = Tuple(map(i-getindex(axes(a), i), perms))

