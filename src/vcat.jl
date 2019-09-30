function Base.vcat(x::AbstractIndex, y::AbstractIndex, z::AbstractIndex...; makeunique::Bool=false)
    vcat(vcat(x, y, makeunique), z...; makeunique=makeunique)
end

function Base.vcat(a::AbstractIndex, b::AbstractIndex; makeunique::Bool=false)
    asindex(
        vcat_keys(a, b, makeunique),
        vcat_values(a, b),
        vcat_names(a, b)
       )
end

"""
    vcat_keys(a, b, makeunique)
"""
vcat_keys(a::AbstractIndex, b::AbstractIndex) = vcat_keys(keys(a), keys(b))

vcat_keys(a::AbstractVector{T1}, b::AbstractVector{T2}) where {T1,T2} = vcat_keys(promote(a, b)...)

vcat_keys(a::OneTo{T}, b::OneTo{T}) where {T} = OneTo{T}(length(a) + length(b))

function vcat_keys(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where {T}
    if first(a) === first(b)
        return UnitRange(first(a), first(a) + length(a) + length(b) - 1)
    else
        error("$a and $b do not have the same first element. Cannot concatenate keys to a common base.")
    end
end

function vcat_keys(a::AbstractRange{T}, b::AbstractRange{T}) where {T}
    if first(a) == first(b) & step(a) == step(b)
        return range(first(a), step=step(a), length=length(a) + length(b))
    else
        error("$a and $b do not have the same first element. Cannot concatenate keys to a common base.")
    end
end

function vcat_keys(a::TupOrVec{T}, b::TupOrVec{T}, makeunique::Bool=false) where {T}
    if makeunique
        # TODO makeunique
    else
        return [a..., b...]
    end
end

"""
    vcat_values(a, b)
"""
vcat_values(a::AbstractIndex, b::AbstractIndex) = vcat_values(values(a), values(b))
vcat_values(a::AbstractUnitRange{T1}, b::AbstractUnitRange{T2}) where {T1,T2} = _combine_values(promote(a, b)...)
vcat_values(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where {T} = a > b ? a : b

"""
    vcat_names(a, b)
"""
@inline vcat_names(a::AbstractIndex, b::AbstractIndex) = vcat_names(dimnames(a), dimnames(b))
vcat_names(a::Nothing, b::Symbol) = b
vcat_names(a::Symbol, b::Nothing) = a
vcat_names(a::Nothing, b::Nothing) = nothing
function vcat_names(a::Symbol, b::Symbol)
    if a === b
        return a
    else
        Symbol("vcat(", a, ",", b, ")")
    end
end
