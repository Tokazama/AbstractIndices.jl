"""
    LabelIndex

Provides a statically labelled index.
"""
struct LabelIndex{label,TA,TI,A,I} <: AbstractIndex{TA,TI,A,I}
    index::I

    function LabelIndex{label,TA,TI,A,I}(index::I) where {label,TA,TI,A,I}
        index_checks(label, index)
        new{label,TA,TI,A,I}(index)
    end
end

LabelIndex(label::NTuple{N,T}) where {N,T} = LabelIndex(label, OneTo(N))

function LabelIndex(label::NTuple{N,TA}, index::AbstractVector{TI}) where {N,TA,TI}
    LabelIndex{label,TA,TI,NTuple{N,TA},typeof(index)}(index)
end

length(::LabelIndex{label}) where {label} = length(label)

to_axis(::LabelIndex{label}) where {label} = label

to_index(li::LabelIndex) = li.index

function to_index(li::LabelIndex{label,TA}, idx::TA) where {label,TA}
    to_index(li)[_to_index(label, idx)]
end

function to_index(li::LabelIndex{label,Int}, idx::Int) where {label,TA}
    to_index(li)[_to_index(label, idx)]
end

function to_index(li::LabelIndex{label,TA}, idx::Int) where {label,TA}
    to_index(li)[idx]
end

_to_index(labels::NTuple{N,T}, idx::Int) where {N,T} = idx


Base.@pure function _to_index(labels::NTuple{N,T}, idx::T) where {N,T}
    # 0-Allocations see: @btime  (()->dim_noerror((:a, :b, :c), :c))()
    for i in 1:N
        getfield(labels, i) === idx && return i
    end
    return 0
end
