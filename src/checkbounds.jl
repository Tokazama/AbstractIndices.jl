
function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::TA) where {TA,TI,A,I}
    firstindex(x) <= i <= lastindex(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::Int) where {TA,TI,A,I}
    firstindex(to_index(x)) <= i <= lastindex(to_index(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,TI,A,I}, i::Int) where {TI,A,I}
    i in to_axis(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::AbstractVector{Int}) where {TA,TI,A,I}
    checkindex(Bool, to_index(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::AbstractVector{TA}) where {TA,TI,A,I}
    _checkindex(to_axis(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,TI,A,I}, i::AbstractVector{Int}) where {TI,A,I}
    _checkindex(to_axis(x), i)
end

_checkindex(axis::AbstractRange{T}, i::AbstractRange{T}) where {T} = issubset(i, axis)


checkbounds(::Type{Bool}, x::AbstractIndex, i::Any) = checkindex(Bool, x, i)
