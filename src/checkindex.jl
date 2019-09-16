function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI}, i::TA) where {TA,TI}
    firstindex(x) <= i <= lastindex(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI}, i::Int) where {TA,TI}
    firstindex(values(x)) <= i <= lastindex(values(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,TI}, i::Int) where {TI}
    i in values(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI}, i::AbstractVector{Int}) where {TA,TI}
    checkindex(Bool, values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI}, i::AbstractVector{TA}) where {TA,TI}
    _checkindex(values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,TI}, i::AbstractVector{Int}) where {TI}
    _checkindex(values(x), i)
end

function checkindex(::Type{Bool}, x::AbstractIndex, i::CartesianIndex{1})
    checkindex(Bool, x, first(i.I))
end

checkindex(::Type{Bool}, x::AbstractIndex{TA,TI}, ::Colon) where {TA,TI} = true

_checkindex(axis::AbstractRange{T}, i::AbstractRange{T}) where {T} = issubset(i, axis)
_checkindex(axis::AbstractRange{T}, i::AbstractIndex{Int}) where {T} = issubset(axis, values(i))


