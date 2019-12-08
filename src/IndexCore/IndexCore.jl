include("abstractindex.jl")
include("param_checks.jl")
include("index.jl")
#include("subindex.jl")    # rewrite, doc, ex, tests
include("simpleindex.jl")
include("iterate.jl")      # rewrite, doc, ex, tests
include("names.jl")
include("size.jl")         # doc, ex, tests
include("reindex.jl")
include("to_index.jl")
include("to_indices.jl")
#include("to_linear.jl")   # rewrite, doc, ex, tests
include("checkindex.jl")   # tests
include("getindex.jl")     # tests
include("combine.jl")      # ex
include("drop_axes.jl")    # tests
include("reduce_axes.jl")  # tests
include("reshape_axes.jl") # doc, ex, tests
include("inverse_axes.jl")
include("covcor_axes.jl")
include("permute_axes.jl") # tests
include("matmul_axes.jl")  # tests
include("filter_axes.jl")  # tests
include("cat_axes.jl")     # tests
include("append_axes.jl")  # doc, ex, tests
include("make_unique.jl")  # doc, ex, tests, TODOs
include("promotion.jl")
include("push_pop.jl")     # doc, ex, tests
#include("prmote_shape.jl")
