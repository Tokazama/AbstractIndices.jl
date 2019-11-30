using AbstractIndices, Test, Statistics

import Base: OneTo

#include("uniqueness_tests.jl")
include("matmul_tests.jl")
include("math_tests.jl")
include("indexing.jl")

#=
include("abstractindex.jl")
include("order.jl")
include("traits.jl")
include("math.jl")
include("reduce.jl")
include("broadcasting.jl")
=#
