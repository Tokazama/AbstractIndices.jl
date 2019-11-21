

function promote_axes(::Type{}, ::Type{})
end

# TODO
function Base.promote_rule(::Type{}, ::Type{}) where {X<:IndicesArray,Y<:AbstractArray}
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:IndicesArray,Y<:IndicesArray}
    return similar_type(X,
                 promote_rule(eltype(X), eltype(Y)),
                 promote_rule(parent_type(X), parent_type(X)),
                 promote_axes(axes_type(X), axes_type(Y))
                )
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:IndicesArray,Y<:AbstractArray}
end

