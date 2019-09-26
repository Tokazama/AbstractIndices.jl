function Base.vcat(a::AbstractIndex, b::AbstractIndex...)
    asindex(vcat(a, keys.(b)...), vcat(b, keys(b)...))
end

# TODO
# - cat
# - hcat
# - join
# - merge
# - intersect
