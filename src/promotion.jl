
# helps with static types that can't be easily inferred as same parametrically
same_type(::Type{X}, ::Type{Y}) where {X<:OneToSRange,Y<:OneToSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:UnitSRange,Y<:UnitSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:StepSRange,Y<:StepSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:LinSRange,Y<:LinSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:StepSRangeLen,Y<:StepSRangeLen} = true
same_type(::Type{X}, ::Type{X}) where {X} = true
same_type(::Type{X}, ::Type{Y}) where {X,Y} = false

function promote_values(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractIndex}
    xv = values_type(X)
    yv = values_type(Y)
    return same_type(xv, yv) ? xv : _promote_rule(xv, yv)
end

function promote_keys(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractIndex}
    xv = keys_type(X)
    yv = keys_type(Y)
    return same_type(xv, yv) ? xv : _promote_rule(xv, yv)
end

function _promote_rule(::Type{X}, ::Type{Y}) where {X,Y}
    out = promote_rule(X, Y)
    return out <: Union{} ? promote_rule(Y, X) : out
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractIndex}
    return similar_type(X, promote_keys(X, Y), promote_values(X, Y))
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractUnitRange}
    return promote_rule(X, similar_type(X, index_keys_type(Y),Y))
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:UnitRange,Y<:AbstractIndex}
    return promote_rule(Y, X)
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractVector}
    return promote_rule(values_type(X), Y)
end
function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractVector,Y<:AbstractIndex}
    return promote_rule(Y, X)
end


#function promote_axes(::Type{X}, ::Type{Y}) where {X<:AbstractIndex,Y<:AbstractIndex}
#end

# TODO
#function Base.promote_rule(::Type{}, ::Type{}) where {X<:IndicesArray,Y<:AbstractArray}
#end
#=
function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:IndicesArray,Y<:IndicesArray}
    return similar_type(X,
                 promote_rule(eltype(X), eltype(Y)),
                 promote_rule(parent_type(X), parent_type(X)),
                 promote_axes(axes_type(X), axes_type(Y))
                )
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:IndicesArray,Y<:AbstractArray}
end
=#
