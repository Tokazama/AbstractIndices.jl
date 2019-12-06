###
### combine_indices
###
"""
    combine_indices
"""
function combine_indices(x::Tuple, y::Tuple)
    return (combine(first(x), first(y)), combine_indices(tail(x), tail(y))...)
end
combine_indices(x::Tuple{Any}, y::Tuple{}) = (first(x),)
combine_indices(x::Tuple{}, y::Tuple{Any}) = (first(y),)
combine_indices(x::Tuple{}, y::Tuple{}) = ()

"""
    combine(x, y)
"""
function combine(x::Index, y::Index)
    return Index{combine_names(x, y)}(combine_keys(x, y), combine_values(x, y))
end
function combine(x::AbstractIndex, y::AbstractIndex)
    error("`combine` must be defined for new subtypes of AbstractIndex.")
end

"""
    combine_values(x::AbstractIndex, y::AbstractIndex)
"""
function combine_values(x::AbstractIndex, y::AbstractIndex)
    return combine_values(promote_values_rule(x, y), values(x), values(y))
end
combine_values(::Type{T}, x, y) where {T<:AbstractUnitRange} = T(x)

"""
    combine_keys(x::AbstractIndex, y::AbstractIndex)

Returns the combined keys of `x` and `y`. Customize behavior for combining
subtypes of `AbstractIndex` by overloading this method.
"""
function combine_keys(x::AbstractIndex, y::AbstractIndex)
    return combine_keys(promote_keys_rule(x, y),keys(x), keys(y))
end

combine_keys(::Union{}, x, y) = combine_keys(typeof(x), x, y)
combine_keys(::Type{T}, x, y) where {T<:Union{OneTo,OneToRange}} = T(length(x))
combine_keys(::Type{T}, x, y) where {T<:AbstractUnitRange} = T(first(x), last(x))
function combine_keys(::Type{T}, x, y) where {T<:Union{StepRange,AbstractStepRange}}
    return T(first(x), step(x), last(x))
end
function combine_keys(::Type{T}, x, y) where {T<:Union{LinRange,AbstractLinRange}}
    return T(first(x), last(x), length(x))
end
function combine_keys(::Type{T}, x, y) where {T<:Union{StepRangeLen,AbstractStepRangeLen}}
    return T(first(x), step(x), length(x), x.offset)
end
combine_keys(::Type{T}, x, y) where {T<:AbstractVector} = copy(x)

###
### vcat_indices
###
function vcat_indices(x::Index, y::Index)
    return Index{combine_names(x, y)}(vcat_keys(x, y), vcat_values(x, y))
end
vcat_indices(x::AbstractIndex, y::AbstractVector) = vcat_indices(promote(x, y)...)
vcat_indices(x::AbstractVector, y::AbstractIndex) = vcat_indices(promote(x, y)...)

###
### append_indices!
###
function append_indices(x::Index, y::Index)
    return Index{combine_names(x, y)}(append_keys(x, y), append_values(x, y))
end
append_indices(x::AbstractIndex, y::AbstractVector) = append_indices(promote(x, y)...)
append_indices(x::AbstractVector, y::AbstractIndex) = append_indices(promote(x, y)...)

###
### make_unique - Adapted from DataFrames.jl
###
function make_unique!(names::AbstractVector{K}, src::AbstractVector{K}; makeunique::Bool=false) where {K}
    if length(names) == length(src)
        throw(ArgumentError("Length of src doesn't match length of names."))
    end
    seen = Set{K}()
    dups = Int[]
    for i in eachindex(names)
        name = @inbounds(src[i])
        if in(name, seen)
            push!(dups, i)
        else
            names[i] = @inbounds(src[i])
            push!(seen, name)
        end
    end

    if length(dups) > 0
        if !makeunique
            dupstr = join(string.(':', unique(src[dups])), ", ", " and ")
            msg = "Duplicate variable names: $dupstr. Pass makeunique=true " *
                  "to make them unique using a suffix automatically."
            throw(ArgumentError(msg))
        end
    end
    return _make_unique!(names, dups, seen)
end

function _make_unique!(names::AbstractVector{Symbol}, dups, seen)
    for i in dups
        nm = src[i]
        k = 1
        while true
            newnm = Symbol("$(nm)_$k")
            if !in(newnm, seen)
                names[i] = newnm
                push!(seen, newnm)
                break
            end
            k += 1
        end
    end

    return names
end

function _make_unique!(names::AbstractVector{T}, dups, seen) where {T<:AbstractString}
    for i in dups
        nm = src[i]
        k = 1
        while true
            newnm = "$(nm)_$k"
            if !in(newnm, seen)
                names[i] = newnm
                push!(seen, newnm)
                break
            end
            k += 1
        end
    end

    return names
end

function _make_unique!(names::AbstractVector{T}, dups, seen) where {T<:Number}
    base_num = T(round(maximum(names), RoundUp, sigdigits=1))
    for i in dups
        nm = src[i]
        k = 1
        while true
            newnm = T + nm
            if !in(newnm, seen)
                names[i] = newnm
                push!(seen, newnm)
                break
            end
            k += 1
        end
    end

    return names
end


function make_unique(names::AbstractVector{Symbol}; makeunique::Bool=false)
    make_unique!(similar(names), names, makeunique=makeunique)
end
