
function show_rows(
    io::IO,
    row_name::Union{AbstractString,AbstractChar},
    row_values::Vector{Union{AbstractString,AbstractChar}},
    row_name_separator::Union{AbstractString,AbstractChar}="│",
    value_separator::Union{AbstractString,AbstractChar}="  ",
    left_border::Union{AbstractString,AbstractChar}="",
    right_border::Union{AbstractString,AbstractChar}=""
   )
    print(io, left_border)
    print(io, row_name)
    print(io, row_name_separator)
    print(io, first(row_values))
    for i in 2:length(row_values)
        print(io, row_values)
        print(io, value_separator[i])
    end
    print(io, right_border)
    print(io, "\n")
end

function col_width()
end

show(io::IO, ::MIME"text/plain", a::AbstractIndex) = show_index(io, keys(a), values(a))

sprint_colpart(width::Int, s::AbstractVector) = join(map(s->lpad(s, width, " "), s), "  ")

function show_index(io::IO, ks::AbstractRange, vs::AbstractRange)
    print(io, "Index: $(ks) => $(vs)")
end

function show_index(io::IO, ks::TupOrVec, vs::TupOrVec)
    print(io, "Index: \n")
    for (k,v) in zip(ks,vs)
        print(io, "$(k) => $(v)")
    end
end

Base.show(io::IO, ::MIME"text/plain", n::AbstractIndicesArray) = show(io, n)

function show(io::IO, v::AbstractIndicesVector)
    println(io, summary(v))
    limit = get(io, :limit, true)
    if size(v) != (0,)
        if limit
            show(io, v, min(displaysize(io)[1] - 5, length(v)))
        else
            show(io, v, length(v))
        end
    end
end


function show(
    io::IO,
    ::MIME"text/plain",
    m::AbstractIndicesMatrix
   )
    print(io, summary(m))
    limit = get(io, :limit, true)
    println(io)
    if limit
        show(io, m, min(displaysize(io)[1] - 5, size(m, 1)))
    else
        show(io, m, size(m, 1))
    end

end

## ndims==1 is dispatched below
function show(
    io::IO,
    a::AbstractIndicesArray{T,N}
   ) where {T,N}
    print(io, summary(a))
    s = size(a)
    limit = get(io, :limit, true)

    nlinesneeded = prod(s[3:end]) * (s[1] + 3) + 1
    if limit && nlinesneeded > displaysize(io)[1]
        maxnrow = clamp((displaysize(io)[1] - 3) ÷ (prod(s[3:end])) - 3, 3, s[1])
    else
        maxnrow = s[1]
    end
    maxrepeat = displaysize(io)[1] ÷ (maxnrow + 4)
    i = 1
    dn = dimnames(a)
    dn = isnothing(dn) ? ntuple(_->"", ndims(a)) : dn

    for idx in CartesianIndices(size(a)[3:end])
        if i > maxrepeat
            print(io, "\n⋮")
            break
        end
        cartnames = [string(dn[2+i], "=", axes(a, 2+i)[ind]) for (i, ind) in enumerate(idx.I)]
        println(io, "\n")
        println(io, "[:, :, ", join(cartnames, ", "), "] =")
        show(io, a[:, :, idx], maxnrow)
        i += 1
    end
end

#show(io::IO, x::NamedVector) = invoke(show, (IO, NamedArray), io, x)

## compute the ranges to be displayed, plus a total index comprising all ranges.
function compute_range(maxn, n)
    if maxn < n
        hn = div(maxn, 2)
        r = (CartesianIndex(1):CartesianIndex(hn), CartesianIndex(n-hn+1):CartesianIndex(n))
    else
        r = (CartesianIndex(1):CartesianIndex(n),)
    end
    totr = vcat(map(collect, r)...)
    r, totr
end

leftalign(s, l) = rpad(s, l, " ")
rightalign(s, l) = lpad(s, l, " ")
sprint_colpart(width::Int, s::Vector) = join(map(s->lpad(s, width, " "), s), "  ")
function sprint_row(namewidth::Int, name, width::Int, names::Tuple; dots="…", sep=" │ ")
    s = string(leftalign(name, namewidth), sep, sprint_colpart(width, names[1]))
    if length(names)>1
        s = string(s, "  ", dots, "  ", sprint_colpart(width, names[2]))
    end
    s
end

#=
function show(
    io::IO,
    m::Union{AbstractIndicesMatrix,NamedIndicesMatrix},
    row_indices::Tuple{CartesianIndices{1,Tuple{UnitRange{Int64}}},CartesianIndices{1,Tuple{UnitRange{Int64}}}}
   )
end
=#

## for 2D printing
function show(
    io::IO,
    m::Union{AbstractIndicesMatrix,NamedIndicesMatrix},
    maxnrow::Int
   )
    nrow, ncol = size(m)
    limit = get(io, :limit, true)
    ## rows
    rowrange, totrowrange = compute_range(maxnrow, nrow)
    s = [sprint(show, parent(m)[i,j], context=:compact => true) for i=totrowrange, j=1:ncol]
    rowname = keys(axes(m, 1))
    colname = keys(axes(m, 2))
    strlen(x) = length(string(x))
    colwidth = max(maximum(map(length, s)), maximum(map(strlen, colname)))

    dn = dimnames(m)
    dn = isnothing(dn) ? ("","") : dn
    rownamewidth = max(maximum(map(strlen, rowname)), sum(map(length, string.(dn)))+3)
    if limit
        maxncol = div(displaysize(io)[2] - rownamewidth - 4, colwidth+2) # dots, spaces between
    else
        maxncol = ncol
    end

    ## columns
    colrange, totcorange = compute_range(maxncol, ncol)
    ## header
    header = sprint_row(rownamewidth, rightalign(join(string.(dn), "  ╲ "), rownamewidth),
                        colwidth, map(i->colname[i], colrange))
    println(io, header)
    print(io, "─"^(rownamewidth+1), "─", "─"^(length(header)-rownamewidth-2))
    ## data
    l = 1
    for i in 1:length(rowrange)
        if i > 1
            vdots = map(i->["⋮" for i=1:length(i)], colrange)
            println(io)
            print(io, sprint_row(rownamewidth, "⋮", colwidth, vdots, dots="⋱", sep="   "))
        end
        r = rowrange[i]
        for j in CartesianIndices((length(r),))
            row = s[l,:]
            if (i == 1 && j == 1) || (i == length(rowrange) && j == length(r))
                dots = "…"
            else
                dots = " "
            end
            println(io)
            print(io, sprint_row(rownamewidth, rowname[totrowrange[l]], colwidth,
                                 map(r -> row[r], colrange), dots=dots))
            l += 1
        end
    end
end



## special case of sparse matrix, based on base/sparse/sparsematrix.c

function show(
    io::IO,
    v::AbstractIndicesVector,
    maxnrow::Int
   )
    nrow = size(v, 1)
    rownames = values(axes(v,1))
    rowrange, totrowrange = compute_range(maxnrow, nrow)
    s = [sprint(show, parent(v)[i], context=:compact => true) for i=totrowrange]
    colwidth = maximum(map(length,s))
    rownamewidth = max(maximum(map(length, rownames)), 1+length(strdimnames(v)[1]))
    ## header
    println(io, string(leftalign(strdimnames(v, 1), rownamewidth), " │ "))
    print(io, "─"^(rownamewidth+1), "┼", "─"^(colwidth+1))
    ## data
    l = 1
    for i in 1:length(rowrange)
        if i > 1
            vdots = ["⋮"]
            println(io)
            print(io, sprint_row(rownamewidth, "⋮", colwidth, (vdots,), sep="   "))
        end
        r = rowrange[i]
        for j in 1:length(r)
            row = s[l]
            println(io)
            print(io, sprint_row(rownamewidth, rownames[totrowrange[l]], colwidth, ([row],)))
            l += 1
        end
    end
end
#=
function Base.show(
    io::IO,
    x::AbstractVector,
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

=#
