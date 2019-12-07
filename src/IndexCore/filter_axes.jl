"""
    filter_axes(f, a)

Return the axes of `a`, removing those for which `f` is false. The function `f`
is passed one argument.
"""
filter_axes(f::Function, x::AbstractArray) = _catch_empty(_filter_axes(f, axes(x)))
function _filter_axes(f, t::Tuple)
    if f(first(t))
        return (first(t), _filter_axes(f, tail(t))...)
    else
        return _filter_axes(f, tail(t))
    end
end
_filter_axes(f, ::Tuple{}) = ()


