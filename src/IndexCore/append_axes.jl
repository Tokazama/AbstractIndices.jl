"""
    append_axes()
"""
function append_axes(x::Index, y::Index)
    return Index{combine_names(x, y)}(append_keys(x, y), append_values(x, y))
end
append_axes(x::AbstractIndex, y::AbstractVector) = append_axes(promote(x, y)...)
append_axes(x::AbstractVector, y::AbstractIndex) = append_axes(promote(x, y)...)

