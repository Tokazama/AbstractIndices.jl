using AbstractIndices, Test

@testset "AbstractIndex" begin
    float_offset = asindex(2.0:11.0);

    @testset "Array interface" begin
        @test @inferred(length(float_offset)) == 10
        @test @inferred(step(float_offset)) == 1
        @test @inferred(first(float_offset)) == 1
        @test @inferred(firstindex(float_offset)) == 2.0
        @test @inferred(last(float_offset)) == 10
        @test @inferred(lastindex(float_offset)) == 11.0
        @test @inferred(stepindex(float_offset)) == 1.0
        @test @inferred(keytype(float_offset)) == Float64
        @test @inferred(valtype(float_offset)) == Int
    end

    symbol_index = asindex((:one, :two, :three))
    @testset "Symbol Index" begin
        @test @inferred(length(symbol_index)) == 3
        @test @inferred(getindex(symbol_index, :one)) == 1
        @test @inferred(getindex(symbol_index, :three)) == 3
   end
end
