"""
    MarkedIndex

"""
abstract type AbstractMarkedIndex{TK,TV,TA,TI,A,I} <: AbstractAxisIndex{TA,TI,A,I} end

"""
    markers(mi::AbstractMarkedIndex)
"""
function markers(mi::AbstractMarkedIndex)
    error()  # TODO
end

"""
    getmark(x::AbstractMarkedIndex)
"""
getmark(a::AbstractMarkedIndex{TK,TV}, i::TK) where {TK,TV} = getindex(markers(a), i)

getmark(i) = (getmark, i)


"""
    setmark!(x::AbstractMarkedIndex, m::Pair)
"""
setmark!(a::AbstractMarkedIndex, m::Pair) = setmark!(a, last(m), first(m))
function setmark!(a::AbstractMarkedIndex{TK,TV}, val::TV, i::TK) where {TK,TV}
    setindex!(markers(a), val, i)
end

setmark!(val, i) = a -> getmark(a, val, i)

function Base.getproperty(mi::AbstractMarkedIndex{TK,TV}, f::Tuple{typeof(getmark),TK}) where {TK,TV}
    first(f)(mi, last(f))
end

"""
    ismarked(::AbstractVector)
"""
Base.ismarked(mi::AbstractMarkedIndex) = !isempty(markers(mi))

"""
    MarkedIndex

# Examples
```jldoctest
julia> mi = mark(1:3, :one => 1)
```
"""
struct MarkedIndex{TK,TV,D<:AbstractDict{TK,TV},TA,TI,A,I,Ax<:AbstractAxisIndex{TA,TI,A,I}} <: AbstractMarkedIndex{TK,TV,TA,TI,A,I}
    axisindex::Ax
    markers::D

    function MarkedIndex{TK,TV,D,TA,TI,A,I,Ax}(
        ai::Ax,
        m::D
       ) where {TK,TV,D,TA,TI,A,I,Ax}
        eltype(TV) <: TA || error("Marker values of a MarkedIndex must return the same axis element type as their corresponding AxisIndex")
        new{TK,TV,D,TA,TI,A,I,Ax}(ai, m)
    end
end

to_axis(mi::MarkedIndex) = axis(getproperty(mi, :axisindex))
to_index(mi::MarkedIndex) = index(getproperty(mi, :axisindex))
markers(mi::MarkedIndex) = getproperty(mi, :markers)

function MarkedIndex(a::AbstractAxisIndex{TA,TI,A,I}, d::AbstractDict{TK,TV}) where {TK,TV,TA,TI,A,I}
    MarkedIndex{TK,TV,typeof(d),TA,TI,A,I,typeof(a)}(a, d)
end

"""
    mark(x::AxisIndex) -> MarkedIndex
"""
Base.mark(a::AbstractVector, ms::Pair...) = MarkedIndex(a, Dict(ms...))
