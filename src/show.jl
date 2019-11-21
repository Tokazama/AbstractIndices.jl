# FIXME show methods here are terrible
function axes_string(a)
    return join(string.(collect(axes(a))), "×")
end

Base.show(io::IO, x::IndicesArray) = show(io, parent(x))
function Base.show(io::IO, m::MIME{Symbol("text/plain")}, x::IndicesArray)
    print(io, "IndicesArray - $(axes_string(x))\n")
    show(io, m, parent(x))
end
