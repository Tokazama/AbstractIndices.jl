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
    return make_unique!(similar(names), names, makeunique=makeunique)
end
