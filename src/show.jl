function Base.show(
    io::IO,
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
        size_max = max(size_max, length(string(keys(x)[i])))
    end
    for i in row_indices
        print(io, lpad(string(keys(x)[i]), size_max))
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
        size_max = max(size_max, length(string(keys(x)[i])))
    end
    for i in last(row_indices)
        size_max = max(size_max, length(string(keys(x)[i])))
    end
 
    for i in first(row_indices)
        print(io, lpad(string(keys(x)[i], size_max)))
        print(io, row_name_separator)
        print(io, string(to_index(x, i)))
        print(io, "\n")
    end

    print(io, repeat(" ", size_max), "⋮")
    print(io, "\n")
    for i in last(row_indices)
        print(io, lpad(string(keys(x)[i]), size_max))
        print(io, row_name_separator)
        print(io, string(to_index(x, i)))
        print(io, "\n")
    end
end
