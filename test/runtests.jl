using AbstractIndices, Test, Statistics

import Base: OneTo

#include("uniqueness_tests.jl")
include("matmul_tests.jl")

@testset "Addition" begin
    a = IndicesArray(ones(3))
    @test +(a) == ones(3)

    @test +(a, a) == 2ones(3)

    @test +(a, a, a) == 3ones(3)
end



#=
include("abstractindex.jl")
include("order.jl")
include("traits.jl")
include("indexing.jl")
include("math.jl")
include("reduce.jl")
include("broadcasting.jl")
=#
