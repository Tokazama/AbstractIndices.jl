
struct NIndex{T<:IndexPrimitiveType,N} <: AbstractVector{T}
    data::NTuple{N,T}

    NIndex{T}(@nospecialize(x::Tuple)) where {T} = new{T,nfields(x)}(x)
    NIndex(@nospecialize(x::Tuple)) = new{eltype(x),nfields(x)}(x)
end

for T in IndexPrimitiveNames
    @eval begin
        @noinline Base.first(x::NIndex{$(T),0}) = throw(BoundsError(x, 0))
        @inline Base.first(x::NIndex{$(T)}) = _get(x, 1)

        @noinline Base.last(x::NIndex{$(T),0}) = throw(BoundsError(x, 0))
        @inline Base.last(x::NIndex{$(T)}) = _get(x, _length(x))

        @inline function Base.iterate(x::NIndex{$(T)})
            @nospecialize x
            (_get(x, 1), 2)
        end
        @inline function Base.iterate(x::NIndex{$(T)}, s::Int)
            @nospecialize x
            s > _length(x) ? nothing : (_get(x, s), s + 1)
        end
    end
end

