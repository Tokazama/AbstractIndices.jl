using AbstractIndices, Test, Statistics

using AbstractIndices: combine, combine_keys, combine_values, combine_names

import Base: OneTo

#include("uniqueness_tests.jl")
include("matmul_tests.jl")
include("math_tests.jl")
include("indexing_tests.jl")
include("abstractindex_tests.jl")
include("broadcasting.jl")
#include("indicesarray_tests.jl")
include("reduce_tests.jl")
include("pop_tests.jl")


#=
include("traits.jl")
include("math.jl")
=#
