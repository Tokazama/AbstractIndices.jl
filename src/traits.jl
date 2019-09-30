"""
    dimnames(x[, i])

Returns the name of `x`. If `x` doesn't have a name then `nothing` is returned.
If `x` is a `Tuple` then `dimnames` is called on each element of `x`. The
optional `i` allows calling `dimnames` on a specific element of a `Tuple` or
returns the ith element of whatever `dimnames` returns. For example, if
`dimnames(x)` returns a tuple of names then the ith name is returned.
"""
dimnames(x::Any) = nothing
dimnames(x::Any, i::Integer) = _dimnames(dimnames(x), i)
_dimnames(::Nothing, i::Integer) = nothing
_dimnames(::Tuple{}, i::Integer) = nothing
_dimnames(t::Tuple{Vararg{Any}}, i::Integer) where {N} = getfield(t, i)

dimnames(::NT) where {NT<:NamedTuple} = fieldnames(NT)
dimnames(::NT, i::Integer) where {NT<:NamedTuple} = fieldname(NT, i)
dimnames(x::Tuple) = merge(dimnames.(x))

function dimnames_error(a, call)
    error("$(typeof(a)) does not have dimension names. Calls to `$(call)` require that `dimnames` be implemented.")
end


"""
    hasdimnames(x) -> Bool

If `x` has dimension names then returns `true`.
"""
hasdimnames(x) = !isnothing(dimnames(x))


"""
    unname(x)

Remove the name from a `x`. If `x` doesn't have a name the same instance of `x`
is returned.
"""
unname(x::Any) = x
unname(nt::NamedTuple{names}) where {names} = Tuple(nt)
unname(x::Tuple) = unname.(x)

"""
    findaxes(f, x)

Returns a tuple of indices for which the axes of `x` are true under `f`. If `x`
has named dimensions this is a tuple of symbols. Otherwise, a tuple of integers
is returned. If all axes return false under the conditions of `f` then
`nothing` is returned.
"""
findaxes(f, a) = _findaxes(f, axes(a), 1)
function _findaxes(f, axs::Tuple{Any,Vararg{Any}}, cnt::Int)
    if f(first(axs))
        return (cnt, _findaxes(f, tail(axs), cnt+1)...)
    else
        return _findaxes(f, tail(axs), cnt+1)
    end
end
_findaxes(f, ::Tuple{}, ::Int) = ()


# TODO finddims doesn't check that int values are inbounds (it just returns them)
# There's no point in doing this because all downstream methods will inevitably
# check that the value is inbounds. But that means that `finddims` would be more
# appropriately named `to_dims` because this is also how `to_index` behaves.
# However, `to_dims` is already in base (to a very limited extent). 
"""
    finddims(a; dims) -> Tuple{Vararg{Int}}

Returns the dimension that has the corresponding `name`. If `name` doesn't
match any of the dimension names `0` is returned. If `img` doesn't have `names`
then the default set of names is searched (e.g., dim_1, dim_2, ...).
"""
finddims(a; dims) = finddims(a, dims)
finddims(x::Any,                   dims::Any                  ) = finddims(dimnames(x), dims)
finddims(a::AbstractArray{T,N},    dims::Colon                ) where {T,N} = ntuple(i -> i, N)::NTuple{N,Int}
finddims(x::Any,                   dims::Tuple{Vararg{Int}}   ) = dims
finddims(::Tuple{Vararg{Nothing}}, dims::Symbol) = 0  # no names to find
finddims(::Nothing, dims::Int) = dims
finddims(::Tuple{Vararg{Any}},     dims::Int   ) = dims
finddims(x::Tuple{Vararg{Union{Symbol,Nothing}}}, dims::Symbol) = _finddims(x, dims)
@inline function finddims(x::Tuple{Vararg{Symbol}}, dims::Tuple{Vararg{<:Union{Symbol,Integer},N}}) where {N}
    Tuple(map(i -> finddims(x, i), 1:N))
end
Base.@pure function _finddims(dn::NTuple{D,<:Union{Nothing,Symbol}}, name::Symbol) where {D}
    for i in 1:D
        getfield(dn, i) === name && return i
    end
    return 0
end

# TODO FIXME error for out of bounds dimension indexing
dim_out_of_bounds(a, i) = error("Attempt to acces dimension $(i) of $(typeof(a)) ")

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
    dropaxes(a; dims)

Returns tuple of axes that don't include `dims`.
"""
dropaxes(a; dims) = dropaxes(a, dims)
dropaxes(a, dims) = _dropaxes(axes(a), finddims(a, dims=dims))

_dropaxes(a, dim::Integer) = _dropaxes(a, (Int(dim),))
function _dropaxes(axs::Tuple{Vararg{<:Any,D}}, dims::NTuple{N,Int}) where {D,N}
    for i in 1:N
        1 <= dims[i] <= D || throw(ArgumentError("dropped dims must be in range 1:ndims(A)"))
        length(axs[i]) == 1 || throw(ArgumentError("dropped dims must all be size 1"))
        for j = 1:i-1
            dims[j] == dims[i] && throw(ArgumentError("dropped dims must be unique"))
        end
    end
    d = ()
    for (i,axis_i) in zip(1:D,axs)
        if !in(i, dims)
            d = tuple(d..., axis_i)
        end
    end
    return d
end


"""
    permuteaxes(a, perms)

Returns axes of `a` in the order of `perms`.
"""
permuteaxes(a, perms) = Tuple(map(i -> getindex(axes(a), i), perms))


"""
    reduceaxis(a)

Reduces axis `a` to single value. Allows custom index types to have custom
behavior throughout reduction methods (e.g., sum, prod, etc.)
"""
reduceaxis(a::AbstractVector{T}) where {T} = one(T)

"""
    reduceaxes(a; dims)
"""
reduceaxes(a; dims) = reduceaxes(a, dims)
reduceaxes(a, dims) = _reduceaxes(axes(a), finddims(a, dims))
_reduceaxes(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduceaxes(axs, (dims,))
function _reduceaxes(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D}
    Tuple(map(i->ifelse(in(i, dims), reduceaxis(axs[i]), axs[i]), 1:D))
end

"""
    namedaxes(a)

Guarantees return of a tuple with named indices.
"""
@inline namedaxes(a) = Tuple(map(i -> namedaxes(a, i), 1:ndims(a)))
namedaxes(a, i::Int) = ensure_name(dimnames(a, i), axes(a, i), i)

ensure_name(name::Symbol, a::TupOrVec, i::Int) = asindex(a, name)
ensure_name(name::Nothing, a::TupOrVec, i::Int) = asindex(a, Symbol(:dim_, i))

"""
    unnamedaxes(a)

Returns tuple of axes with no named dimensions.
"""
unnamedaxes(a) = unname(axes(a))


maybe_tuple(x::Tuple{Any, Vararg}) = x
maybe_tuple(x::Tuple{Any}) = first(x)
maybe_tuple(x::Any) = x

_catch_empty(x::Tuple) = x
_catch_empty(x::NamedTuple) = x
_catch_empty(::Tuple{}) = nothing
_catch_empty(::NamedTuple{(),Tuple{}}) = nothing
