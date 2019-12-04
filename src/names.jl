
dimnames(::AbstractIndex{name}) where {name} = name
dimnames(::AbstractUnitRange) = nothing
dimnames(x::AbstractArray) = dimnames(axes(x))
dimnames(x::AbstractArray, i::Int) = dimnames(axes(x, i))
dimnames(x::Tuple{Any,Vararg}) = (dimnames(first(x)), dimnames(tail(x))...)
dimnames(x::Tuple{}) = ()

combine_names(a::Union{Symbol,Nothing}, b::AbstractIndex) = combine_names(a, dimnames(b))
combine_names(a::AbstractIndex, b::Union{Symbol,Nothing}) = combine_names(dimnames(a), b)
combine_names(a::AbstractIndex, b::AbstractIndex) = combine_names(dimnames(a), dimnames(b))

combine_names(a::Symbol, b::Symbol) = a
combine_names(::Nothing, b::Symbol) = b
combine_names(a::Symbol, ::Nothing) = a
combine_names(::Nothing, ::Nothing) = nothing

"""
    to_dims(a, names) -> NTuple{N,Int}
"""
@inline to_dims(a, names::Tuple{Any,Vararg}) = (to_dim(a, first(names)), to_dims(a, tail(names))...)
to_dims(a, names::Tuple{}) = ()


"""
    to_dim(a, name) -> Int
"""
to_dim(a::AbstractArray, d::Union{Int,Colon}) = d
to_dim(a::AbstractArray, d::Integer) = Int(d)
@inline function to_dim(a::AbstractArray{T,N}, name::Symbol) where {T,N}
    for i in 1:N
        dimnames(a, i) === name && return i
    end
    return 0
end

function to_dim(dnames::Tuple, name::Symbol)::Int
    dimnum = _to_dim(dnames, name)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(name))) does not match any dimension name ($dnames)"
        ))
    end
    return dimnum
end
to_dim(dnames::Tuple, d::Union{Int,Colon}) = d
to_dim(dnames::Tuple, d::Integer) = Int(d)

function _to_dim(dnames::NTuple{N}, name::Symbol) where N
    for ii in 1:N
        getfield(dnames, ii) === name && return ii
    end
    return 0
end
