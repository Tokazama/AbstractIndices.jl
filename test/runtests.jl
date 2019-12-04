using AbstractIndices, Test, Statistics

import Base: OneTo

#include("uniqueness_tests.jl")
include("matmul_tests.jl")
include("math_tests.jl")
include("indexing_tests.jl")
include("abstractindex_tests.jl")
include("reduce_tests.jl")


#=
include("traits.jl")
include("math.jl")
include("broadcasting.jl")
=#
