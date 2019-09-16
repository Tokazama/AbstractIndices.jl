"""
    AxisIndex
"""
struct AxisIndex{TA,TI,A,I} <: AbstractIndex{TA,TI,A,I}
    axis::A
    index::I

    function AxisIndex{TA,TI,A,I}(axiss::A, index::I) where {TA,TI,A,I}
        index_checks(axis, index)
        new{TA,TI,A,I}(axis, index)
    end
end

Base.keys(x::AxisIndex{TA,TI,A,I}) where {TA,TI,A,I} = OneTo(length(x))
Base.keys(x::AxisIndex{TA,TI,A,I}, i::Int) where {TA,TI,A,I} = i

Base.values(x::AxisIndex) = x.index
Base.values(x::AxisIndex{T}, i::T) where {T} = searchsortedfirst(values(x), i)

