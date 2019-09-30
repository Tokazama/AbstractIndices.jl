"""
    maybe_dimnames(a, call, maybe)

If `a` has dimension names (i.e. `HasDimNames(a) -> HasDimNames{true}()`) then
returns `dimnames(a)`. Otherwise returns `maybe(a, call)`. Useful for throwing
errors that show the offending method in the stack trace.
"""
maybe_dimnames(a::Any, call, maybe) = _maybe_dimnames(dimnames(a), a, call, maybe)
_maybe_dimnames(name::Symbol, a, call, maybe) = name
_maybe_dimnames(   ::Nothing, a, call, maybe) = maybe(a, call)

axes_error(a, call) = error("$(typeof(a)) does not have axes. Calls to `$(call)` require that `axes` be implemented.")

"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{K,V,Ks,Vs} <: AbstractVector{V} end

Base.valtype(::Type{<:AbstractIndex{K,V}}) where {K,V} = V

Base.keytype(::Type{<:AbstractIndex{K,V}}) where {K,V} = K

Base.length(a::AbstractIndex) = length(values(a))

Base.size(a::AbstractIndex) = (length(a),)

Base.first(a::AbstractIndex) = first(values(a))

Base.last(a::AbstractIndex) = last(values(a))

Base.step(a::AbstractIndex) = step(values(a))

Base.firstindex(a::AbstractIndex) = first(keys(a))

Base.isempty(a::AbstractIndex) = length(a) == 0

Base.lastindex(a::AbstractIndex) = last(keys(a))

Base.haskey(a::AbstractIndex{K}, key::K) where {K} = key in keys(a)
Base.haskey(a::AbstractIndex{K1}, key::K2) where {K1,K2} = throw(ArgumentError("invalid key: $key of type $K2"))

# TODO don't love these names but seem most appropriate for now
# ideally we could have valeltype, valtype, keyeltype, and keytype; but this
# behavior wouldn't be consistent with what we find in base where keytype
# refers to an element rather than container
#
# maybe change keystype => axistype and valuestype => indextype
keystype(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Ks
valuestype(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Vs


have_same_values(::AbstractIndex{K1,V1,Ks1,Vs1}, ::AbstractIndex{K2,V2,Ks2,Vs2}) where {K1,V1,Ks1,Vs1,K2,V2,Ks2,Vs2} = false
have_same_values(::AbstractIndex{K1,V,Ks1,OneTo{V}}, ::AbstractIndex{K2,V,Ks2,OneTo{V}}) where {K1,V,Ks1,K2,Ks2} = true
have_same_values(::AbstractIndex{K,V,Ks,Vs}, ::Vs) where {K,V,Ks,Vs} = true
have_same_values(::AbstractIndex{K,V,Ks,Vs}, ::Vs2) where {K,V,Ks,Vs,Vs2<:AbstractVector} = true

# only `T<:AbstractUnitRange` can broadcast in base. Until we have a good
# reason to expand on this behavior we should probably just restrict to it.
can_broadcast(::T) where {T<:AbstractIndex} = can_broadcast(T)
can_broadcast(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = false
can_broadcast(::Type{<:AbstractIndex{K,V,Ks,Vs}}) where {K,V,Ks,Vs<:AbstractUnitRange} = true

"""
    UnitRangeIndex
"""
abstract type UnitRangeIndex{K,V,Ks,Vs<:AbstractUnitRange{V}} <: AbstractIndex{K,V,Ks,Vs} end

Base.allunique(::UnitRangeIndex) = true


"""
    AbstractOneTo

Abstract type for index keys that wrap a simple `OneTo` set of values.
"""
abstract type AbstractOneTo{K,V,Ks} <: UnitRangeIndex{K,V,Ks,OneTo{V}} end

values(a::AbstractOneTo{K,V,Ks}) where {K,V,Ks} = OneTo{V}(length(a))
length(a::AbstractOneTo) = length(keys(a))


"""
    NamedIndex

A subtype of `AbstractIndex` with a name.
"""
struct NamedIndex{name,K,V,Ks,Vs,I<:AbstractIndex{K,V,Ks,Vs}} <: AbstractIndex{K,V,Ks,Vs}
    index::I

    function NamedIndex{name,K,V,Ks,Vs,I}(index::I) where {name,K,V,Ks,Vs,I}
        new{name,K,V,Ks,Vs,I}(index)
    end
end

const NamedUnitRangeIndex{name,K,V,Ks,Vs,I<:UnitRangeIndex{K,V,Ks,Vs}} = NamedIndex{name,K,V,Ks,Vs,I}

# ≈ Base.DimOrInd
const DimOrIndex = Union{Integer,AbstractUnitRange,UnitRangeIndex,NamedUnitRangeIndex}


function Base.CartesianIndices(axs::Tuple{Vararg{DimOrIndex}})
    CartesianIndices(values.(axs))
end

function Base.LinearIndices(axs::Tuple{Vararg{DimOrIndex}})
    LinearIndices(values.(axs))
end

"""
    UniqueChecked

This allows circumventing checking keys for unique keys at construction time if
this is done elsewhere. If this is used without knowing that all keys provided
to a structure are unique then unexpected behavior is likely to occur.
"""
struct CheckedUnique{T} end

const CheckedUniqueTrue = CheckedUnique{true}()

const CheckedUniqueFalse = CheckedUnique{false}()

CheckedUnique(x::AbstractVector) = CheckedUniqueFalse
CheckedUnique(x::Tuple) = CheckedUniqueFalse
CheckedUnique(x::AbstractRange) = CheckedUniqueTrue


