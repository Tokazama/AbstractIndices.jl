
struct SubIndex{T,P,I} <: AbstractVector{T}
    parent::P
    index::I

    global function _SubIndex(@nospecialize(x), @nospecialize(i))
        new{eltype(x),typeof(x),typeof(i)}(x, i)
    end
end

@assume_effects :nothrow _parent(@nospecialize x::SubIndex) = getfield(x, :parent)
@assume_effects :nothrow _index(@nospecialize x::SubIndex) = getfield(x, :index)

Base.@propagate_inbounds Base.getindex(x::SubIndex, i::Int) = _get(_parent(x), _parent(x)[i])



function Base.view(x::Union{NIndex,OpaqueIndex}, i::AbstractVector{Int})
    @boundscheck checkbounds(x, i)
    _SubIndex(x, i)
end

