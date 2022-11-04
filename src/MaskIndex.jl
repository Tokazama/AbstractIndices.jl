
@nospecialize

struct MaskIndex{N} <: AbstractVector{Int}
    data::NTuple{N,Bool}
    sum::Int

    global _MaskIndex(x::Tuple{Vararg{Bool}}, n::Int) = new{nfields(x)}(x, n)
end
MaskIndex(x::Tuple{Vararg{Bool}}) = _MaskIndex(x, _count_true(x))
MaskIndex(x::NIndices{Bool}) = MaskIndex(_tuple(x))

@assume_effects :nothrow :consistent _mask(x::MaskIndex) = getfield(x, :data)

Base.firstindex(x::MaskIndex) = 1
_cnt(x::MaskIndex) = getfield(x, :sum)
Base.length(x::MaskIndex) = _cnt(x)
Base.lastindex(x::MaskIndex) = _cnt(x)

Base.Tuple(x::MaskIndex) = (x...,)


Base.eltype(x::Union{Type{<:MaskIndex},MaskIndex}) = Int
Base.collect(x::MaskIndex) = NIndices{Int}((x...,))
function Base.iterate(x::MaskIndex)
    @inline
    if _cnt(x) === 0
        return nothing
    else
        i = _find_first_true(_mask(x))
        return (i, (i + 1, 1))
    end
end
function Base.iterate(x::MaskIndex, s::Tuple{Int,Int})
    @inline
    value = _get(s, 1)
    index = _get(s, 2)
    if index === _cnt(x)  # no more true values past this point
        return nothing
    else
        i = _find_next_true(_mask(x), value)
        return (i, (i + 1, index + 1))
    end
end
#endregion iterate

Base.show(io::IO, x::MaskIndex) = print(io, collect(x))
Base.print_array(io::IO, x::MaskIndex) = Base.print_array(io, collect(x))

@specialize
