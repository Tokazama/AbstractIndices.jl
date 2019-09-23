show(io::IO, a::AbstractIndex) = show_index(io, keys(a), values(a))

function show_index(io::IO, ks::AbstractRange, vs::AbstractRange)
    print(io, "Index: $(ks) => $(vs)")
end

function show_index(io::IO, ks::TupOrVec, vs::TupOrVec)
    print(io, "Index: \n")
    for (k,v) in zip(ks,vs)
        print(io, " $(k) => $(v)")
        print(io, "\n")
    end
end

Base.print_matrix(io::IO, a::AbstractIndex) = show_index(io, keys(a), values(a))

###
### Array show
###

function Base.summary(a::AbstractIndicesArray{T,N}) where {T,N}
    string(join(size(a), "×"), " ", typeof(a).name, "{", T, ",", N, "}")
end


function Base.show(io::IO, ::MIME"text/plain", n::Union{AbstractIndicesArray,NamedIndicesArray})
   show(io, n)
end

sprint_colpart(width::Int, s::AbstractVector) = join(map(s->lpad(s, width, " "), s), "  ")

function show(io::IO, v::Union{AbstractIndicesVector,NamedIndicesVector})
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

function show(io::IO, ::MIME"text/plain", m::Union{AbstractIndicesMatrix,NamedIndicesMatrix})
    show(io, m)
end

function show(
    io::IO,
    m::Union{AbstractIndicesMatrix,NamedIndicesMatrix}
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
function show(io::IO, a::Union{AbstractIndicesArray,NamedIndicesArray})
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
        cartnames = [string(dn[2+i], keys(axes(a, 2+i))[ind]) for (i, ind) in enumerate(idx.I)]
        println(io, "\n")
        println(io, "[:, :, ", join(cartnames, ", "), "] =")
        show(io, a[:, :, map(CartesianIndex, idx.I)...], maxnrow)
        i += 1
    end
end

## compute the ranges to be displayed, plus a total index comprising all ranges.
## FIXME what's the abstractindex doing here
function compute_range(v::AbstractIndex, maxn, n)
    if maxn < n
        hn = div(maxn, 2)
        r = (CartesianIndex(1):CartesianIndex(hn), CartesianIndex(n-hn+1):CartesianIndex(n))
    else
        r = (CartesianIndex(1):CartesianIndex(n),)
    end
    totr = vcat(map(collect, r)...)
    r, totr
end

function compute_range(v::AbstractPosition, maxn, n)
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
    maxnrow::Int,
    dimnames_separator::Union{AbstractString,AbstractChar}=" ╲ "
   )
    nrow, ncol = size(m)
    limit = get(io, :limit, true)
    ## rows
    rowrange, totrowrange = compute_range(axes(m, 1), maxnrow, nrow)
    if m isa NamedIndicesMatrix
        s = [sprint(show, parent(parent(m))[i,j], context=:compact => true) for i=totrowrange, j=axes(m, 2)]
    else
        # FIXME
        #s = [sprint(show, parent(m[i,j], context=:compact => true) for i=totrowrange, j=axes(m, 2)]
        s = [sprint(show, parent(m)[i,j], context=:compact => true) for i=totrowrange, j=axes(m, 2)]
    end
    rowname = keys(axes(m, 1))
    colname = keys(axes(m, 2))
    strlen(x) = length(string(x))
    colwidth = max(maximum(map(length, s)), maximum(map(strlen, colname)))

    dn = dimnames(m)
    if dn == (:_, :_)
        dns = ""
        dn = ("", "")
    else
        dns = dimnames_separator
    end
    rownamewidth = max(maximum(map(strlen, rowname)), sum(map(length, string.(dn)))+length(dns))
    if limit
        maxncol = div(displaysize(io)[2] - rownamewidth - 4, colwidth+2) # dots, spaces between
    else
        maxncol = ncol
    end

    ## columns
    colrange, totcorange = compute_range(axes(m, 1), maxncol, ncol)
    ## header
    header = sprint_row(rownamewidth, rightalign(join(string.(dn), dns), rownamewidth),
                        colwidth, map(i->colname[i], colrange))
    println(io, header)
    print(io, "─"^(rownamewidth+1), "─", "─"^(length(header)-rownamewidth-2))
    ## data
    l = 1
    for i in CartesianIndices((length(rowrange),))
        if first(i.I) > 1
            vdots = map(i->["⋮" for i=1:length(i)], colrange)
            print(io, "\n")
            print(io, sprint_row(rownamewidth, "⋮", colwidth, vdots, dots="⋱", sep="   "))
        end
        r = rowrange[i]
        for j in CartesianIndices((length(r),))
            row = s[l,:]
            if (first(i.I) == 1 && first(j.I) == 1) || (first(i.I) == length(rowrange) && first(j.I) == length(r))
                dots = "…"
            else
                dots = " "
            end
            print(io, "\n")
            print(io, sprint_row(rownamewidth, rowname[totrowrange[l]], colwidth,
                                 map(r -> row[r], colrange), dots=dots))
            l += 1
        end
    end
end



## special case of sparse matrix, based on base/sparse/sparsematrix.c

function show(
    io::IO,
    v::Union{AbstractIndicesVector,NamedIndicesVector},
    maxnrow::Int
   )
    nrow = size(v, 1)
    rownames = values(axes(v,1))
    rowrange, totrowrange = compute_range(axes(v, 1), maxnrow, nrow)
    if v isa NamedIndicesVector
        s = [sprint(show, parent(parent(v))[i], context=:compact => true) for i=totrowrange]
    else
        s = [sprint(show, parent(v)[i], context=:compact => true) for i=totrowrange]
    end
    dn = dimnames(v)
    if dn == (:_,)
        dn = ""
    else
        dn = string(first(dn))
    end
 
    colwidth = maximum(map(length,s))
    rownamewidth = max(maximum(map(length, rownames)), 1+length(dn))
    ## header
    println(io, string(leftalign(dn, rownamewidth), " │ "))
    print(io, "─"^(rownamewidth+1), "─", "─"^(colwidth+1))
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
