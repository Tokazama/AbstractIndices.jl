
@testset "AbstractIndex" begin
    float_offset = asindex(2.0:11.0);  # --> should be OneToIndex
    int_offset = asindex(2:11, 1:10) # --> should be AxisIndex
    symbol_index = StaticKeys((:one, :two, :three))

    @testset "Range interface" begin
        @test @inferred(length(float_offset)) == 10
        @test @inferred(step(float_offset)) == 1
        @test @inferred(first(float_offset)) == 1
        @test @inferred(firstindex(float_offset)) == 2.0
        @test @inferred(last(float_offset)) == 10
        @test @inferred(lastindex(float_offset)) == 11.0
        @test @inferred(keytype(float_offset)) == Float64
        @test @inferred(valtype(float_offset)) == Int
    end

    @testset "Symbol Index" begin
        @test @inferred(length(symbol_index)) == 3
        @test @inferred(getindex(symbol_index, :one)) == 1
        @test @inferred(getindex(symbol_index, :three)) == 3
   end

   @testset "iterate vs pairs" begin
        i, state = iterate(symbol_index)
        p = IndexPosition(symbol_index)
        @test (i, state) == (p, p)

        i, state = iterate(symbol_index, state)
        p._state += CartesianIndex(1)
        @test (i, state) == (p, p)

        i, state = iterate(symbol_index, state)
        p._state += CartesianIndex(1)
        @test (i, state) == (p, p)

        @test collect(pairs(symbol_index)) == [:one => 1, :two => 2, :three => 3]

   end

end

