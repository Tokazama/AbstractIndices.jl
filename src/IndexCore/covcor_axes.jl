"""
    covcor_axes
"""
covcor_axes(x::AbstractMatrix, dims::Int) = covcor_axes(axes(x), dims)
covcor_axes(x::NTuple{2}, dims::Int) = dims === 1 ? (x[2], x[2]) : (x[1], x[1])

