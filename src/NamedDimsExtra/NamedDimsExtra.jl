module NamedDimsExtra

using NamedDims

import Base: tail, to_dim

export DimNames,
       HasDimNames,
       HasAxes,
       TimeDim,
       ColorDim,
       dimnames,
       iscolordim,
       istimedim,
       filteraxes,
       findaxes,
       namedaxes


"""
    HasDimNames
"""
struct HasDimNames{T} end
const HDNTrue = HasDimNames{true}()
const HDNFalse = HasDimNames{false}()

HasDimNames(x::T) where T = HasDimNames(T)
HasDimNames(::Type{T}) where T = HDNFalse

no_dimnames_error(a) = error("Type of $(typeof(a)) has no dimension names.")

"""
    HasAxes
"""
struct HasAxes{T} end
const HATrue = HasAxes{true}()
const HAFalse = HasAxes{false}()

HasAxes(x::T) where T = HasAxes(T)
HasAxes(::Type{T}) where T = HAFalse
HasAxes(::Type{T}) where T<:AbstractArray = HATrue

no_axes_error(a) = error("Type of $(typeof(a)) has no axes.")

"""
    dimnames
"""
function dimnames end

"""
    DimName{Sym}

Represents the dimension name.
"""
struct DimName{Sym} end

const TimeDim = DimName{:time}()
const ColorDim = DimName{:color}()

"""
    dimnames

"""
dimnames(::DimName{Sym}) where {Sym} = Sym
function dimnames(x::Tuple{Vararg{<:DimName,N}}) where {N}
    map(dimnames, x)::NTuple{N,Symbol}
end

istimedim(::DimName{:time}) = true
istimedim(::Any) = false

iscolordim(::DimName{:color}) = true
iscolordim(::Any) = false

eqdim(::D1, ::D2) where {D1<:DimName,D2<:DimName} = eqdim(D1, D2)
eqdim(::D, n::Symbol) where {D<:DimName} = eqdim(D, n)
eqdim(n::Symbol, ::D) where {D<:DimName} = eqdim(D, n)
eqdim(::Type{DimName{name}}, ::Type{DimName{name}}) where {name} = true
eqdim(::Type{DimName{name1}}, ::Type{DimName{name2}}) where {name1,name2} = false
eqdim(::Type{DimName{name}}, n::Symbol) where {name} = name === n
eqdim(n::Symbol, ::Type{DimName{name}}) where {name} = name === n

Base.axes(x::Any, d::DimName) = axes(x, to_dim(x, d))

"""
    to_dim(x, n)
"""
to_dim(x::Any, n::NTuple{N}) where {N} = map(to_dim, n)::NTuple{N,Int}
to_dim(x::T, n::Int) where {T} = _to_dim(HasDimNames(T), x, n)::Int
to_dim(x::T, n::Union{Symbol,DimName}) where {T} = _to_dim(HasDimNames(T), x, n)::Int

_to_dim(::HasDimNames{false}, x, n) = no_dimnames_error(x)

function _to_dim(::HasDimNames{true}, x::Any, n::Symbol)
    dimnum = _to_dim_symbol(dimnames(x), n)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(n))) does not match any dimension name ($dimnames(x))"
        ))
    end
    return dimnum
end

function _to_dim(::HasDimNames{true}, x::Any, n::DimName)
    dimnum = _to_dim_dim(dimnames(x), n)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(n))) does not match any dimension name ($dimnames(x))"
        ))
    end
    return dimnum
end


_to_dim(::HasAxes{true}, x, n::Int) = _to_dim_int(axes(x), n)

Base.@pure function _to_dim_int(::Tuple{Vararg{Any,N}}, i::Int) where {N}
    if i < 1 || i > N
        throw(ArgumentError("Specified dimension, $i, not within $nd dimensions."))
    else
        return i
    end
end

Base.@pure function _to_dim_symbol(dimnames::NTuple{N,Symbol}, name::Symbol) where N
    for ii in 1:N
        getfield(dimnames, ii) === name && return ii
    end
    return 0
end

Base.@pure function _to_dim_dim(dimnames::NTuple{N,Symbol}, ::DimName{name}) where {N,name}
    for ii in 1:N
        getfield(dimnames, ii) === name && return ii
    end
    return 0
end

#Base.dropdims(a; dims::DimName) = dropdims(a, dims=to_dim(a, dims))
function Base.permutedims(a::AbstractArray, perm::Tuple{Vararg{<:DimName}})
    permutedims(a, to_dim(a, perm))
end

"""
    namedfirst(x::NamedTuple) -> NamedTuple

Returns the first element of `x` with it's accompanying key as a `NamedTuple`.
"""
namedfirst(x::NamedTuple) = NamedTuple{(first(keys(x)),)}((first(x),))

"""
    filteraxes(f, a)

Return the axes of `a`, removing those for which `f` is false. The function `f`
is passed one argument.
"""
filteraxes(f, x) = _catch_empty(_filteraxes(HasDimNames(x), f, x))
_filteraxes(::HasDimNames{true}, f, x) = __filteraxes(f, namedaxes(x))
_filteraxes(::HasDimNames{false}, f, x) = _findaxes(HasAxes(x), f, x)
_filteraxes(::HasAxes{true}, f, x) = __filteraxes(f, axes(x))
_filteraxes(::HasAxes{false}, f, x) = no_axes_error(x)

function __filteraxes(f, t::Tuple)
    if f(first(t))
        return (first(t), __filteraxes(f, tail(t))...)
    else
        return __filteraxes(f, tail(t))
    end
end
function __filteraxes(f, t::NamedTuple)
    if f(namedfirst(t))
        return (namedfirst(t), __filteraxes(f, tail(t))...)
    else
        return __filteraxes(f, tail(t))
    end
end
_filteraxes(f, ::NamedTuple{(),Tuple{}}) = NamedTuple{(),Tuple{}}()
_filteraxes(f, ::Tuple{}) = ()

"""
    findaxes(f, x)

Returns a tuple of indices for which the axes of `x` are true under `f`. If `x`
has named dimensions this is a tuple of symbols. Otherwise, a tuple of integers
is returned. If all axes return false under the conditions of `f` then
`nothing` is returned.
"""
findaxes(f, x) = _catch_empty(_findaxes(HasDimNames(x), f, x))
_findaxes(::HasDimNames{true}, f, x) = __findaxes(f, namedaxes(x))
_findaxes(::HasDimNames{false}, f, x) = _findaxes(HasAxes(x), f, x)
_findaxes(::HasAxes{true}, f, x) = __findaxes(f, axes(x), 1)
_findaxes(::HasAxes{false}, f, x) = no_axes_error(x)


function __findaxes(f, t::Tuple, cnt::Int)
    if f(first(t))
        return (cnt, __findaxes(f, tail(t), cnt+1)...)
    else
        return __findaxes(f, tail(t), cnt+1)
    end
end

function __findaxes(f, t::NamedTuple{names}) where {names}
    if f(namedfirst(t))
        return (first(names), __findaxes(f, tail(t))...)
    else
        return __findaxes(f, tail(t))
    end
end

__findaxes(f, ::Tuple{}) = ()
__findaxes(f, ::NamedTuple{(),Tuple{}}) = ()

_catch_empty(x::Tuple) = x
_catch_empty(x::NamedTuple) = x
_catch_empty(::Tuple{}) = nothing
_catch_empty(::NamedTuple{(),Tuple{}}) = nothing

"""
    namedaxes
"""
namedaxes(x::T) where T = _namedaxes(HasDimNames(T), HasAxes(T), x)
_namedaxes(::HasDimNames{true}, ::HasAxes{true}, x) = NamedTuple{dimnames(x)}(axes(x))
_namedaxes(::HasDimNames{Any}, ::HasAxes{Any}, x) = nothing

namedaxes(x::T, i) where {T} = _namedaxes(HasDimNames(T), HasAxes(T), x, i)
_namedaxes(::HasDimNames{true}, ::HasAxes{true}, x, i::Int) = NamedTuple{(dimnames(x, i),)}((axes(x, i),))
_namedaxes(::HasDimNames{true}, ::HasAxes{true}, x, i::Symbol) = NamedTuple{(i,)}((to_axes(x, i),))

end
