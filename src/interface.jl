# mapfilteraxes
# filterdims
"""
    HasDimNames

Trait that guarantees implementation of the `dimnames` method for a given type.
"""
struct HasDimNames{T} end
const HDNTrue = HasDimNames{true}()
const HDNFalse = HasDimNames{false}()

HasDimNames(x::T) where T = HasDimNames(T)
HasDimNames(::Type{T}) where T = HDNFalse

function dimnames_error(a, call)
    error("$(typeof(a)) does not have dimension names. Calls to `$(call)` require that `dimnames` be implemented.")
end

hasdimnames(::T) where {T} = hasdimnames(T)
hasdimnames(::Type{T}) where {T} = HasDimNames{true} === HasDimNames(T)

"""
    maybe_dimnames(a, call, maybe)

If `a` has dimension names (i.e. `HasDimNames(a) -> HasDimNames{true}()`) then
returns `dimnames(a)`. Otherwise returns `maybe(a, call)`.
"""
maybe_dimnames(a::A, call, maybe) where {A} = _maybe_dimnames(HasDimNames(A), a, call, maybe)
_maybe_dimnames(::HasDimNames{true}, a, call, maybe) = dimnames(a)
_maybe_dimnames(::HasDimNames{false}, a, call, maybe) = maybe(a, call)

"""
    dimnames(x) -> Tuple

"""
dimnames(x::Any) = nothing
dimnames(x::Any, i::Integer) = _dimnames(dimnames(x), i)
_dimnames(::Nothing, i::Integer) = nothing
_dimnames(::Tuple{}, i::Integer) = nothing
_dimnames(t::NTuple{N,Symbol}, i::Integer) where {N} = getfield(t, i)

dimnames(::NT) where {NT<:NamedTuple} = fieldnames(NT)
dimnames(::NT, i::Integer) where {NT<:NamedTuple} = fieldname(NT, i)
dimnames(x::Tuple) = merge(dimnames.(x))

dimnames(::Type{<:AbstractArray{T, N}}) where {T, N} = ntuple(_->:_, N)

"""
    unname(x)

"""
unname(x::Any) = x
unname(nt::NamedTuple{names}) where {names} = Tuple(nt)
unname(x::Tuple) = unname.(x)


"""
    HasAxes

Trait that guarantees implementation of `axes` method for a given type.
"""
struct HasAxes{T} end

const HATrue = HasAxes{true}()
const HAFalse = HasAxes{false}()

HasAxes(x::T) where T = HasAxes(T)
HasAxes(::Type{T}) where T = HAFalse
HasAxes(::Type{T}) where T<:AbstractArray = HATrue

axes_error(a, call) = error("$(typeof(a)) does not have axes. Calls to `$(call)` require that `axes` be implemented.")

"""
    maybe_axes(a, call, maybe)

If `a` has axes (i.e. `HasAxes(a) -> HasAxes{true}()`) then returns `axes(a)`.
Otherwise returns `maybe(a, call)`.
"""
maybe_axes(a::A, call, maybe) where {A} = _maybe_axes(HasAxes(A), a, call, maybe)
_maybe_axes(::HasAxes{true}, a, call, maybe) = axes(a)
_maybe_axes(::HasAxes{false}, a, call, maybe) = maybe(a, call)

"""
    findaxes(f, x)

Returns a tuple of indices for which the axes of `x` are true under `f`. If `x`
has named dimensions this is a tuple of symbols. Otherwise, a tuple of integers
is returned. If all axes return false under the conditions of `f` then
`nothing` is returned.
"""
findaxes(f, a) = _findaxes(f, maybe_axes(a, findaxes, (x,y) -> ()), 1)
function _findaxes(f, t::Tuple, cnt::Int)
    if f(first(t))
        return (cnt, _findaxes(f, tail(t), cnt+1)...)
    else
        return _findaxes(f, tail(t), cnt+1)
    end
end
_findaxes(f, ::Tuple{}, ::Int) = ()


# TODO does it make more sense to have return of Tuple{Int} become Int?
"""
    finddims(a; dims) -> Tuple{Vararg{Int}}

Returns the dimension that has the corresponding `name`. If `name` doesn't
match any of the dimension names `0` is returned. If `img` doesn't have `names`
then the default set of names is searched (e.g., dim_1, dim_2, ...).
"""
finddims(a; dims) = finddims(a, dims)
finddims(a, dims) = maybe_tuple(_finddims(maybe_dimnames(a, finddims, (x,y) -> ntuple(i -> i, ndims(x))), dims))
_finddims(d::Tuple, name::Symbol) = __finddims(d, name)
_finddims(d::Tuple, dims::NTuple{N,Symbol}) where {N} = Tuple(map(i -> __finddims(d, i), dims))
_finddims(d::Tuple, dims::Union{Integer,Tuple{Vararg{Int}}}) = dims  # FIXME should this also check for out of bounds
_finddims(d::Tuple{Vararg{Any,N}}, dims::Colon) where {N} = ntuple(i -> i, N)::NTuple{N,Int}
_finddims(::Nothing, dims) = nothing

Base.@pure function __finddims(dn::NTuple{D,Symbol}, name::Symbol) where {D}
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
dropaxes(a, dims) = _dropaxes(maybe_axes(a, dropaxes, (x, y) -> axes_error(x, y)), finddims(a, dims=dims))

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
reduceaxes(a, dims) = _reduceaxes(maybe_axes(a, reduceaxes, (x,y)->axes_error(x, y)), finddims(a, dims))
_reduceaxes(axs::Tuple{Vararg{Any,D}}, dims::Int) where {D} = _reduceaxes(axs, (dims,))
_reduceaxes(axs::Tuple{Vararg{Any,D}}, dims::Tuple{Vararg{Int}}) where {D} = Tuple(map(i->ifelse(in(i, dims), reduceaxis(axs[i]), axs[i]), 1:D))

"""
    namedaxes(a)

Guarantees return of a tuple with named indices.
"""
namedaxes(a) = _namedaxes(axes(a), 1)
_namedaxes(a::Tuple{Vararg{Any,N}}, i::Int) where {N} = (ensure_name(first(a), i), _namedaxes(tail(a), i+1)...)
_namedaxes(a::Tuple{}, i::Int) = ()

ensure_name(a::A, i::Int) where {A} = _ensure_name(HasDimNames(A), a, i)
_ensure_name(::HasDimNames{true}, a, i) = asindex(a)
_ensure_name(::HasDimNames{false}, a, i) = asindex(a, Symbol(:dim_, i))

maybe_tuple(x::Tuple{Any, Vararg}) = x
maybe_tuple(x::Tuple{Any}) = first(x)
maybe_tuple(x::Any) = x

_catch_empty(x::Tuple) = x
_catch_empty(x::NamedTuple) = x
_catch_empty(::Tuple{}) = nothing
_catch_empty(::NamedTuple{(),Tuple{}}) = nothing


# TODO ensure no unnecessary allocations
@inline combine_names(a::A, b::B) where {A,B} = combine_names(dimnames(a), dimnames(b))
combine_names(a::Nothing, b::Symbol) = b
combine_names(a::Symbol, b::Nothing) = a
combine_names(a::Nothing, b::Nothing) = nothing
function combine_names(a::Symbol, b::Symbol)
    if a === b
        return a
    else
        Symbol(a, :-, b)
    end
end

# FIXME combine_keys(::NTuple, )
combine_keys(a::TupOrVec{K}, b::TupOrVec{K}) where {K} = unique((a..., b...))

# TODO: how to combine keys instead of simply choosing the longest?
combine_keys(a::AbstractRange, b::AbstractRange) = length(a) > length(b) ? a : b

