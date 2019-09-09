"""
    LabelIndex

Provides a statically labelled index.
"""
struct LabelIndex{label,TA,TI,A,I} <: AbstractIndex{TA,TI,A,I}
    index::I

    function LabelIndex{label,TA,TI,A,I}(index::AbstractVector{TI}) where {label,TA,TI,A,I}
        index_checks(label, index)
        new{label,TA,TI,A,I}(index)
    end
end

length(::LabelIndex{label}) where {label} = length(label)

function LabelIndex(label::NTuple{N,T}, index::AbstractVector{TA}) where {N,T,TA}
    LabelIndex{label,TA,T,NTuple{N,T},typeof(index)}(index)
end

