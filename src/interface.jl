"""
    HasDimNames

Trait that guarantees implementation of the `dimnames` method for a given type.
"""
struct HasDimNames{T} end
const HDNTrue = HasDimNames{true}()
const HDNFalse = HasDimNames{false}()

HasDimNames(x::T) where T = HasDimNames(T)
HasDimNames(::Type{T}) where T = HDNFalse

HasDimNames(::Type{T}) where {T<:NamedDimsArray} = HDNTrue

no_dimnames_error(a) = error("Type of $(typeof(a)) has no dimension names.")


"""
    dimnames(x) -> Tuple


"""
dimnames(x::Any) = ()
dimnames(x::Any, i::Integer) = _dimnames(dimnames(x), i)
_dimnames(::Tuple{}, i::Integer) = nothing
_dimnames(t::NTuple{N,Symbol}, i::Integer) where {N} = getfield(t, i)

dimnames(::NT) where {NT<:NamedTuple} = fieldnames(NT)
dimnames(::NT, i::Integer) where {NT<:NamedTuple} = fieldname(NT, i)
dimnames(x::Tuple) = merge(dimnames.(x))

dimnames(::Type{<:NamedDimsArray{names}}) where {names} = names
dimnames(::Type{<:AbstractArray{T, N}}) where {T, N} = ntuple(_->:_, N)

"""
    unname(x)

"""
unname(x::Any) = x
unname(nt::NamedTuple{names}) where {names} = Tuple(nt)
unname(x::Tuple) = unname.(x)


"""
    HasAxes
"""
struct HasAxes{T} end

const HATrue = HasAxes{true}()
const HAFalse = HasAxes{false}()

HasAxes(x::T) where T = HasAxes(T)
HasAxes(::Type{T}) where T = HAFalse
HasAxes(::Type{T}) where T<:AbstractArray = HATrue

function no_axes_error(f, a)
    error()
end

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
    finddim(img, name) -> Int

Returns the dimension that has the corresponding `name`. If `name` doesn't
match any of the dimension names `0` is returned. If `img` doesn't have `names`
then the default set of names is searched (e.g., dim_1, dim_2, ...).
"""
@inline finddim(a::A, name::Symbol) where {A} = _finddim(HasDimNames(A), a, name)
_finddim(::HasDimNames{false}, a, name::Symbol) = nothing
function _finddim(::HasDimNames{true}, a, name::Symbol)
   i =  __finddim(dimnames(a), name)
   if i === 0
       dim_out_of_bounds(a, name)
   else
       return i
   end
end

# FIXME should this checkbounds or just hand that off to next function?
finddim(a::Any, i::Integer) = 1  

Base.@pure function __finddim(dimnames::NTuple{N,Symbol}, name::Symbol) where {N}
    for i in 1:N
        getfield(dimnames, i) === name && return i
    end
    return 0
end

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
dropaxes(a::A; dims) where {A} = dropaxes(HasAxes(A), a, finddim(a, dims))
dropaxes(::HasAxes{true}, a, dims) = _dropaxes(a, dims)
dropaxes(::HasAxes{false}, a, dims) = no_axes_error(dropaxes, a)

_dropaxes(a, dim::Integer) = _dropdims(a, (Int(dim),))
function _dropaxes(axs::Tuple{Vararg{<:Any,D}}, dim::NTuple{N,Int}) where {D,N}
    for i in 1:N
        1 <= dims[i] <= ndims(A) || throw(ArgumentError("dropped dims must be in range 1:ndims(A)"))
        length(axes(A, dims[i])) == 1 || throw(ArgumentError("dropped dims must all be size 1"))
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
function permuteaxes(a, perms)
    Tuple(map(i-getindex(axes(a), i), perms))
end


"""
    permutedimnames
"""
permutedimnames(a, perms) = Tuple(map(i->getindex(axes(a), i), perms))


# TODO axis point
"""
axispoint
"""
function axispoint end

"""
    reducedim
"""
function reducedim(a::AbstractIndex, dims, i::Int)
    if any(i .== dims)
        return SingleIndex(a)
    else
        return a
    end
end

"""
    reduceaxes
"""
reduceaxes(a::AbstractIndicesArray{T,N}; dims::Colon) where {T,N} = ()
function reduceaxes(a::AbstractIndicesArray{T,N}, dims) where {T,N}
    Tuple(map(i->reducedim(axes(a, i), dims, i), 1:N))
end

function findin(r::AbstractRange{<:Integer}, span::AbstractUnitRange{<:Integer})
    local ifirst
    local ilast
    fspan = first(span)
    lspan = last(span)
    fr = first(r)
    lr = last(r)
    sr = step(r)
    if sr > 0
        ifirst = fr >= fspan ? 1 : ceil(Integer,(fspan-fr)/sr)+1
        ilast = lr <= lspan ? length(r) : length(r) - ceil(Integer,(lr-lspan)/sr)
    elseif sr < 0
        ifirst = fr <= lspan ? 1 : ceil(Integer,(lspan-fr)/sr)+1
        ilast = lr >= fspan ? length(r) : length(r) - ceil(Integer,(lr-fspan)/sr)
    else
        ifirst = fr >= fspan ? 1 : length(r)+1
        ilast = fr <= lspan ? length(r) : 0
    end
    r isa AbstractUnitRange ? (ifirst:ilast) : (ifirst:1:ilast)
end
