
function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::TA) where {TA,TI,A,I}
    firstindex(x) <= i <= lastindex(x)
end

function checkindex(::Type{Bool}, x::AbstractIndex{TA,TI,A,I}, i::Int) where {TA,TI,A,I}
    firstindex(to_index(x)) <= i <= lastindex(to_index(x))
end

function checkindex(::Type{Bool}, x::AbstractIndex{Int,TI,A,I}, i::Int) where {TI,A,I}
    i in to_axis(x)
end
