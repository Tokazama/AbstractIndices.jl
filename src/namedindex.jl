abstract type AbstractNamedIndex{D,TA,TI} <: AbstractIndex{TA,TI} end

struct NamedIndex{D,TA,TI,I<:AbstractIndex{TA,TI}} <: AbstractNamedIndex{D,TA,TI}
    index::I
end

function NamedIndex{D}(x::AbstractIndex{TA,TI}) where {D,TA,TI}
    NamedIndex{D,TA,TI,typeof(x)}(index)
end

NamedIndex{D}(x::AbstractVector) where {D} = NamedIndex{D}(asindex(x))

(d::Dim{name})(x::AbstractVector) = NamedIndex{d}(x)



