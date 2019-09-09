abstract type AbstractIndex{TA,TI,A,I} <: AbstractVector{TI} end

Base.length(ai::AbstractIndex) = length(to_index(ai))

Base.size(ai::AbstractIndex) = (length(ai),)

Base.first(ai::AbstractIndex) = first(to_index(ai))

Base.last(ai::AbstractIndex) = last(to_index(ai))

Base.step(ai::AbstractIndex) = step(to_index(ai))

Base.firstindex(ai::AbstractIndex) = first(to_axis(ai))

"""
    stepindex(x) -> Real

Returns the step size of the index.
"""
stepindex(ai::AbstractIndex) = step(to_axis(ai))

Base.lastindex(ai::AbstractIndex) = last(to_axis(ai))

"""
    to_axis(x)

Returns the axis associated with an `AbstractIndex`.
"""
to_axis(x::AbstractIndex) = error("All subtypes of AbstractIndex must define `to_axis")
to_axis(x::AbstractIndex, i) = getindex(to_axis(x), i)
to_axis(x::AbstractIndex, i::AbstractVector) = getindex(to_axis(x), i)
to_axis(x::AbstractIndex, i::Colon) = to_axis(x)

"""
    axistype
"""
axistype(::T) where {T<:AbstractIndex} = axistype(T)

axistype(::Type{<:AbstractIndex{TA,TI,A,I}}) where {TA,TI,A,I} = A

"""
    axiseltype
"""
axiseltype(::T) where {T<:AbstractIndex} = axiseltype(T)

axiseltype(::Type{<:AbstractIndex{TA,TI,A,I}}) where {TA,TI,A,I} = TA

"""
    to_index
"""
function to_index(x::AbstractIndex{TA,TI,A,I}, i::TA) where {TA,TI,A,I}
    searchsortedfirst(to_index(x), i)
end

# axistype is not Int so assume user wants to directly go to index
function to_index(x::AbstractIndex{TA,TI,A,I}, i::Int) where {TA,TI,A,I}
    getindex(to_index(x), i)
end

# axistype is Int so assume user is interfacing to index through the axis
function to_index(x::AbstractIndex{Int,TI,A,I}, i::Int) where {TI,A,I}
    getindex(to_index(x), searchsortedfirst(to_axis(x), i))
end

function to_index(x::AbstractIndex{TA,TI,A,I}, inds::AbstractVector{TA}) where {TA,TI,A,I}
    map(i -> to_index(x, i), inds)
end

function to_index(x::AbstractIndex{TA,TI,<:AbstractRange,I}, inds::AbstractRange{TA}) where {TA,TI,I}
    to_index(x, first(inds)):round(Integer, step(inds) / step(x)):to_index(x, last(inds))
end

to_index(x::AbstractIndex, i::Colon) = to_index(x)


"""
    indextype(::Type{AbstractIndex}) -> Type{::AbstractVector}
    indextype(::AbstractIndex) -> Type{::AbstractVector}

Returns the index type associated with an `AbstractIndex`.
"""
indextype(::T) where {T<:AbstractIndex} = indextype(T)

indextype(::Type{<:AbstractIndex{TA,TI,A,I}}) where {TA,TI,A,I} = I

"""
    indexeltype

Returns the element type of the index associated with an `AbstractIndex`.
"""
indexeltype(::T) where {T<:AbstractIndex} = indexeltype(T)
indexeltype(::Type{<:AbstractIndex{TA,TI,A,I}}) where {TA,TI,A,I} = TI


#Base.iterate(x::AbstractIndex) = first(to_index(x)), first(to_axis(x))

function Base.iterate(x::AbstractIndex)
    idx, state = iterate(to_axis(x))
    @inbounds (idx, getindex(x, idx)), state
end

function Base.iterate(x::AbstractIndex, state)
    nextstate = iterate(to_axis(x), state)
    _iterate(x, nextstate)
end

_iterate(x::AbstractIndex, ::Nothing) = nothing
function _iterate(x::AbstractIndex, state::Tuple{TA,S}) where {TA,S}
    @inbounds getindex(to_index(x, first(state)), last(state))
end


const AbstractAxesIndex{N} = Tuple{Vararg{<:AbstractIndex,N}}
