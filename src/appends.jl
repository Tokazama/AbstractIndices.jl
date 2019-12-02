
function Base.append!(a::IndicesVector, b::AbstractVector)
    append_index!(a, b)
    append!(parent(a), b)
    return a
end

function Base.append!(a::IndicesVector, b::IndicesVector)
    append_index!(a, b)
    append!(parent(a), parent(b))
    return a
end

function append_index!(a::AbstractIndex, b::AbstractIndex)
    _append_keys!(keys(a), keys(b))
    _append_values!(values(a), values(b))
    return a
end

_append_keys!(a, b) = _append_keys!(Continuity(a), a, b)

_append_keys!(::ContinuousTrait, a, b) = set_length!(a, length(a) + length(b))

function _append_keys!(::DiscreteTrait, a::AbstractVector{A}, ::ContinuousTrait, b::AbstractVector{B}) where {A,B}

    for a_i in a
        for b_i in b
            push!(a, a == B(b_i) ?  : b_i)
        end
    end
end

function _append_keys!(::DiscreteTrait, a::AbstractVector{T}, ::ContinuousTrait, b::AbstractVector{T}) where {T}
    for a_i in a
        for b_i in b
            if a == b
                push!(a, a == B(b_i) ?  : b_i)
            end
        end
    end
end


