struct SkipPoint end

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

function show(
    io::IO,
    ::MIME"text/plain",
    a::AbstractIndicesArray,
    row_col_name::Union{AbstractString,AbstractChar}="  ",
    row_name_separator::Union{AbstractString,AbstractChar}="-",
    col_name_separator::Union{AbstractString,AbstractChar}="  ",
    row_value_separator::Union{AbstractString,AbstractChar}="  ",
    hdots::AbstractString = "  \u2026  ",
    vdots::AbstractString = "\u22ee",
    ddots::AbstractString = "  \u22f1  ",
    label_slices::Bool=true;
    kwargs...
   )
    limit::Bool = get(io, :limit, false)
    if isempty(a)
        return
    end
    tailinds = tail(tail(axes(a)))
    nd = ndims(a)-2
    for I in CartesianIndices(tailinds)
        idxs = I.I
        if limit
            for i = 1:nd
                ii = idxs[i]
                ind = tailinds[i]
                if length(ind) > 10
                    if ii == ind[firstindex(ind)+3] && all(d->idxs[d]==first(tailinds[d]),1:i-1)
                        for j=i+1:nd
                            szj = length(axes(a, j+2))
                            indj = tailinds[j]
                            if szj>10 && first(indj)+2 < idxs[j] <= last(indj)-3
                                @goto skip
                            end
                        end
                        #println(io, idxs)
                        print(io, "...\n\n")
                        @goto skip
                    end
                    if ind[firstindex(ind)+2] < ii <= ind[end-3]
                        @goto skip
                    end
                end
            end
        end
        if label_slices
            print(io, "[:, :, ")
            for i = 1:(nd-1); print(io, "$(idxs[i]), "); end
            println(io, idxs[end], "] =")
        end
        slice = view(a, axes(a,1), axes(a,2), idxs...)
        show_indices_matrix(
            io,
            slice,
            row_col_name,
            row_name_separator,
            row_value_separator,
            col_name_separator,
            vdots,
            hdots,
            ddots;
            kwargs...
           )
        print(io, idxs == map(last,tailinds) ? "" : "\n\n")
        @label skip
    end
end

"""
    show_indices_matrix
"""
function show_indices_matrix(
    io::IO,
    X::Union{AbstractIndicesMatrix,SubIndicesMatrix},
    row_col_name::Union{AbstractString,AbstractChar}="  ",
    row_name_separator::AbstractString="-",
    row_value_separator::AbstractString="  ",
    col_value_separator::Union{AbstractString,AbstractChar}="  ",
    vdots::AbstractString="  \u2026  ",
    hdots::AbstractString="\u22ee",
    ddots::AbstractString="  \u22f1  ";
    kwargs...
   )
    sz = displaysize(io)
    row_axes = axes(X, 1)
    col_axes = axes(X, 2)
    row_indices, row_name_size = get_row_indices(row_axes, first(sz), row_col_name; kwargs...)
    col_indices, col_value_sizes = get_col_indices(col_axes, sz[2], row_indices, row_name_size, row_name_separator, row_value_separator)

    print_header(
        io,
        row_col_name,
        row_name_separator,
        col_axes,
        col_indices,
        col_value_sizes,
        col_value_separator;
        kwargs...
       )

    for row_index in row_indices
        print_rows(
            io,
            X,
            row_index,
            col_indices,
            col_value_sizes,
            to_axis(row_axes, row_index),
            row_name_size, row_name_separator, row_value_separator, vdots,
            ddots; kwargs...
           )
    end
end

"""
    print_header
"""
function print_header(
    io::IO,
    row_col_name::AbstractString,
    row_name_separator::Union{AbstractString,AbstractChar},
    col_axes::AbstractIndex,
    col_indices::AbstractVector,
    col_value_sizes::AbstractVector,
    col_value_separator::Union{AbstractString,AbstractChar};
    kwargs...
   )
   print(io, row_col_name)
   print(io, row_name_separator)
   for (col_idx, col_size) in zip(col_indices, col_value_sizes)
       print_value(io, to_axis(col_axes, col_idx), col_size; kwargs...)
       print(io, col_value_separator)
   end
end

"""
    get_row_indices
"""
function get_row_indices(
    x::AbstractIndex,
    displayheight::Int,
    row_col_name::AbstractString;
    kwargs...
   )
    x_len = length(x)
    row_name_size = length(row_col_name)
    if x_len > displayheight
        half_height = div(x_len, 2)
        for i in to_axis(x, 1:half_height)
            row_name_size = max(row_name_size, length(prep_value(i, 0; kwargs...)))
        end
        for i in to_axis(x, (x_len - half_height):x_len)
            row_name_size = max(row_name_size, length(prep_value(i, 0; kwargs...)))
        end
        [1:half_height..., SkipPoint(), (x_len - half_height):x_len...], row_name_size
    else
        for i in to_axis(x)
            row_name_size = max(row_name_size, length(prep_value(i, 0; kwargs...)))
        end
        return 1:x_len, row_name_size
    end
end

"""
    get_col_indices
"""
function get_col_indices(
    X::AbstractMatrix,
    col_axes::AbstractIndex,
    row_indices::AbstractVector,
    displaywidth::Int,
    row_name_size::Int,
    row_name_separator::AbstractString,
    row_value_separator::AbstractString;
    kwargs...
   )
    screen_width_remaining = displaywidth - (row_name_size + length(row_name_separator))
    first_col_indices = Int[]
    last_col_indices = Int[]
    first_col_size = Int[]
    last_col_size = Int[]
    first_idx = firstindex(col_axes)
    last_idx = lastindex(col_axes)
    while true
        maxcolwidthfirst = length(prep_value(first_idx; kwargs...))
        for row_i in row_indices
            maxcolwidthfirst = max(maxcolwidthfirst, length(prep_value(X[row_i,first_idx], 0; kwargs...)))
        end
        if screen_width_remaining > maxcolwidthfirst
            push!(first_col_indices, first_idx)
            push!(first_col_size, maxcolwidthfirst)
            screen_width_remaining -= maxcolwidthfirst
        else
            break
        end

        maxcolwidthlast = length(prep_value(last_idx, 0; kwargs...))
        for row_i in row_indices
            maxcolwidthlast = max(maxcolwidthlast, length(prep_value(X[row_i,last_idx], 0; kwargs...)))
        end
        if screen_width_remaining > maxcolwidthlast
            push!(last_col_indices, last_idx)
            push!(last_col_size, maxcolwidthlast)
            screen_width_remaining -= maxcolwidthlast
        else
            break
        end

        first_idx = nextind(col_axes, first_idx)
        if first_idx == last_idx
            break
        end
        last_idx = prevind(col_axes, last_idx)
        if first_idx == last_idx  # last index to do is same so finish now and break
            maxcolwidthfirst = length(prep_value(first_idx, 0; kwargs...))
            for row_i in row_indices
                maxcolwidthfirst = max(maxcolwidthfirst, length(prep_value(X[row_i,first_idx], 0; kwargs...)))
            end
            if screen_width_remaining > maxcolwidthfirst
                push!(first_col_indices, first_idx)
                push!(first_col_size, maxcolwidthfirst)
            else
                break
            end
            break
        end
    end
    append!(first_col_indices, last_col_indices)
    append!(first_col_size, last_col_size)

    return first_col_indices, first_col_size
end

"""
    print_row()
"""
function print_rows(
    io::IO,
    X::AbstractMatrix,
    row_index::Any,
    col_indices::AbstractVector,
    col_value_sizes::Vector{Int},
    row_name::Any,
    row_name_size::Int,
    row_name_separator::AbstractString,
    row_value_separator::AbstractString,
    vdots::AbstractString,
    ddots::AbstractString;
    kwargs...
   )
    print_value(io, row_name, row_name_size; kwargs...)
    print(io, row_value_separator)
    for (col_index,col_size) in zip(col_indices,col_value_sizes)
        print_col_at_row(
            io,
            X,
            row_index,
            col_index,
            col_size,
            row_value_separator,
            ddots;
            kwargs...
           )
    end
    print(io, "\n")
end


function print_rows(
    io::IO,
    X::AbstractMatrix,
    row_index::SkipPoint,
    col_indices::AbstractVector,
    col_value_sizes::Vector{Int},
    row_name::Any,
    row_name_size::Int,
    row_name_separator::AbstractString,
    row_value_separator::AbstractString,
    vdots::AbstractString,
    ddots::AbstractString;
    kwargs...
   )
    print(io, repeat(" ", row_name_size + length(row_name_separator)))
    for (col_index,col_size) in zip(col_indices,col_value_sizes)
        print_col_at_row(
            io,
            X,
            row_index,
            col_index,
            col_size,
            row_value_separator,
            ddots;
            kwargs...
           )
    end
    print(io, "\n")
end

"""
    print_col_at_row

Helps determine if ddots are printed or value.
"""
function print_col_at_row(
    io::IO,
    x::AbstractMatrix,
    row_index::Any,
    col_index::Any,
    col_value_size::Int,
    row_value_separator::Union{AbstractString,AbstractChar},
    ddots::AbstractString;
    kwargs...
   )
    print_value(io, x[row_index, col_index], col_value_size)
end


function print_col_at_row(
    io::IO,
    x::AbstractMatrix,
    row_index::SkipPoint,
    col_index::Any,
    col_value_size::Int,
    row_value_separator::Union{AbstractString,AbstractChar},
    ddots::AbstractString;
    kwargs...
   )
    print(io, repeat(" ", col_value_size + length(row_value_separator)))
end

function print_col_at_row(
    io::IO,
    x::AbstractMatrix,
    row_index::SkipPoint,
    col_index::SkipPoint,
    col_value_size::Int,
    row_value_separator::Union{AbstractString,AbstractChar},
    ddots::AbstractString;
    kwargs...
   )
   print(io, ddots)
end

"""
    print_value

This is where the value is converted into a `String` and appropriately formated
for printing.
"""
function print_value(io::IO, val::Any, npad::Int; kwargs...)
    print_value(io, prep_value(val, npad,; kwargs...))
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

