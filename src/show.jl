function Base.show(
    io::IO,
    ::MIME"text/plain",
    x::AbstractIndex,
    row_name_separator::Union{AbstractString,AbstractChar}=" - ",
    row_value_separator::Union{AbstractString,AbstractChar}=" ",
   )
    sz = displaysize(io)
    size_x = length(x)
    if size_x > first(sz)
        half_sz = div(first(sz), 2)
        inds = (1:half_sz, (size_x - half_sz):size_x)
    else
        inds = 1:size_x
    end
    show_rows(io, x, inds, row_name_separator, row_value_separator)
end

function show_rows(
    io::IO,
    x::AbstractIndex,
    row_indices::AbstractVector,
    row_name_separator::Union{AbstractString,AbstractChar},
    row_value_separator::Union{AbstractString,AbstractChar}
   )
    size_max = 0
    for i in row_indices
        size_max = max(size_max, length(string(to_axis(x, i))))
    end
    for i in row_indices
        print(io, lpad(string(to_axis(x, i)), size_max))
        print(io, row_name_separator)
        print(io, string(to_index(x, i)))
        print(io, "\n")
    end
end

function show_rows(
    io::IO,
    x::AbstractIndex,
    row_indices::Tuple{AbstractVector,AbstractVector},
    row_name::Union{AbstractString,AbstractChar},
    row_value::Union{AbstractString,AbstractChar},
    row_name_separator::Union{AbstractString,AbstractChar},
    row_value_separator::Union{AbstractString,AbstractChar}
   )
    size_max = 0
    for i in first(row_indices)
        size_max = max(size_max, length(string(to_axis(x, i))))
    end
    for i in last(row_indices)
        size_max = max(size_max, length(string(to_axis(x, i))))
    end
 
    for i in first(row_indices)
        print(io, lpad(string(to_axis(x, i)), size_max))
        print(io, row_name_separator)
        print(io, string(to_index(x, i)))
        print(io, "\n")
    end

    print(io, repeat(" ", size_max), "⋮")
    print(io, "\n")
    for i in last(row_indices)
        print(io, lpad(string(to_axis(x, i)), size_max))
        print(io, row_name_separator)
        print(io, string(to_index(x, i)))
        print(io, "\n")
    end
end

"""
    prep_value(val, npad; kwargs...)

Prepares value for printing within and array print out.

# Arguments
"""
function prep_value(
    val::Real,
    npad::Int;
    r::RoundingMode=RoundNearest,
    sigdigits::Int=2,
    base::Int=10,
    kwargs...
    )
    prep_value(string(round(val, r, sigdigits=sigdigits, base=base)), npad; kwargs...)
end

function prep_value(val::Any, npad::Int; kwargs...)
    prep_value(string(val), npad; kwargs...)
end


function prep_value(val::String, npad::Int; side_of_padding=rpad)
    side_of_padding(val, npad)
end

