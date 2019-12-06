# `sort` and `sort!` don't change the index, just as it wouldn't on a normal vector
# TODO cusmum!, cumprod! tests
# 1 Arg - no default for `dims` keyword
for (mod, funs) in ((:Base, (:cumsum, :cumprod, :sort, :sort!)),)
    for fun in funs
        @eval function $mod.$fun(a::AbstractIndicesArray; dims, kwargs...)
            return IndicesArray($mod.$fun(parent(a), dims=dims, kwargs...), axes(a))
        end

        # Vector case
        @eval function $mod.$fun(a::AbstractIndicesVector; kwargs...)
            return IndicesArray($mod.$fun(parent(a); kwargs...), axes(a))
        end
    end
end
