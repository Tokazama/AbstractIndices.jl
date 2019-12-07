"""
    vcat_axes
"""
function vcat_axes(x::Index, y::Index)
    return Index{combine_names(x, y)}(vcat_keys(x, y), vcat_values(x, y))
end
vcat_axes(x::AbstractIndex, y::AbstractVector) = vcat_axes(promote(x, y)...)
vcat_axes(x::AbstractVector, y::AbstractIndex) = vcat_axes(promote(x, y)...)
