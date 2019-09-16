### to_index
function to_index(x::AbstractIndex{TA,TI,A,I}, i::TA) where {TA,TI,A,I}
    searchsortedfirst(values(x), i)
end

# axistype is not Int so assume user wants to directly go to index
function to_index(x::AbstractIndex{TA,TI,A,I}, i::Int) where {TA,TI,A,I}
    getindex(values(x), i)
end

# axistype is Int so assume user is interfacing to index through the axis
function to_index(x::AbstractIndex{Int,TI,A,I}, i::Int) where {TI,A,I}
    getindex(values(x), searchsortedfirst(keys(x), i))
end

function to_index(x::AbstractIndex{TA,TI,A,I}, inds::AbstractVector{TA}) where {TA,TI,A,I}
    map(i -> to_index(x, i), inds)
end

function to_index(x::AbstractIndex{TA,TI,<:AbstractRange,I}, inds::AbstractRange{TA}) where {TA,TI,I}
    to_index(x, first(inds)):round(Integer, step(inds) / step(x)):to_index(x, last(inds))
end

to_index(x::AbstractIndex, i::Colon) = values(x)

# the one exception to the Int-axis Int-index problem, in other words
# a CartesianIndex always goes traight to the index and not through the axis
to_index(x::AbstractIndex, i::CartesianIndex{1}) = to_index(values(x), first(i.I))



