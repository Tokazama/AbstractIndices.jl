
@testset "AbstractIndex" begin
    float_offset = asindex(2.0:11.0);  # --> should be OneToIndex
    int_offset = asindex(2:11, 1:10) # --> should be AxisIndex
    symbol_index = StaticKeys((:one, :two, :three))

    @testset "Type interface" begin
        @test @inferred(valtype(float_offset)) == Int
        @test @inferred(keytype(float_offset)) == Float64
        @test @inferred(isempty(float_offset)) == false
        @test @inferred(length(float_offset)) == 10
        @test @inferred(dimnames(float_offset)) == nothing
        @test @inferred(unname(float_offset)) == float_offset
        @test @inferred(step(float_offset)) == 1
        @test @inferred(first(float_offset)) == 1
        @test @inferred(firstindex(float_offset)) == 2.0
        @test @inferred(last(float_offset)) == 10
        @test @inferred(lastindex(float_offset)) == 11.0
        @test @inferred(valtype(float_offset)) == Int
    end

    @testset "Symbol Index" begin
        @test @inferred(keys(symbol_index)) == (:one, :two, :three)
        @test @inferred(values(symbol_index)) == Base.OneTo(3)
        @test @inferred(length(symbol_index)) == 3
        @test @inferred(allunique(symbol_index)) == allunique(keys(symbol_index))
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

    @testset "NamedIndex" begin
        r1 = range(.1, stop = .2, length=5)
        r2 = ["a", "b", "c", "d"]
        r3 = 2:4

        ind1 = asindex(r1, :a)
        ind1_uint = asindex(asindex(r1, OneTo(UInt(5))), :a)
        ind2 = asindex(r2, :b)
        ind3 = asindex(r3, :c)


        @test asindex(ind1, OneTo(5)) == ind1
        @test asindex(ind1, OneTo(UInt(5))) == ind1_uint
        @test asindex(ind1, ind1) == ind1
        @test asindex(r1, ind1) == ind1
        @test asindex(ind1, ind2) == ind1

        ind4 = asindex(r1, ind1)
        @test values(ind4) == OneTo(5)
    end
end

