"""
    AbstractIndex

An `AbstractVector` subtype optimized for indexing. See ['asindex'](@ref) for
detailed examples describing its behavior.
"""
abstract type AbstractIndex{TA,TI,A,I} <: AbstractVector{TI} end

Base.valtype(::Type{<:AbstractIndex{TA,TI}}) where {TA,TI} = TI

Base.keytype(::Type{<:AbstractIndex{TA,TI}}) where {TA,TI} = TA

Base.length(ai::AbstractIndex) = length(values(ai))

Base.size(ai::AbstractIndex) = (length(ai),)

Base.first(ai::AbstractIndex) = first(values(ai))

Base.last(ai::AbstractIndex) = last(values(ai))

Base.step(ai::AbstractIndex) = step(values(ai))

Base.firstindex(ai::AbstractIndex) = first(keys(ai))


"""
    stepindex(x) -> Real

Returns the step size of the index.
"""
stepindex(ai::AbstractIndex) = step(keys(ai))

Base.lastindex(ai::AbstractIndex) = last(keys(ai))



Base.iterate(x::AbstractIndex) = iterate(keys(x))

Base.iterate(x::AbstractIndex, state) = iterate(keys(x), state)


# TODO rethink setaxis!
"""
    setaxis!(A::AxisIndex, val, i)

The equivalent of `setindex` for the axis values of `A`.
"""
function setaxis!(ai::AbstractIndex, val::Any, i::Any)
    @boundscheck checkbounds(keys(ai), i)
    @inbounds setindex!(keys(ai), val, to_index(keys(ai), i))
end


function Base.getindex(ai::AbstractIndex, i::Any)
    @boundscheck if !checkindex(Bool, ai, i)
        throw(BoundsError(ai, i))
    end
    @inbounds to_index(ai, i)
end

Base.getindex(x::AbstractIndex, i::Colon) = x

function Base.CartesianIndices(axs::Tuple{Vararg{<:AbstractIndex,N}}) where {N}
    CartesianIndices(values.(axs))
end

Base.Slice(x::AbstractIndex) = Base.Slice(values(x))
