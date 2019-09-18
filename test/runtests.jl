using AbstractIndices, Test

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
        @test @inferred(stepindex(float_offset)) == 1.0
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
        @test (i, state) == (1, 1)
        i, state = iterate(symbol_index, state)
        @test (i, state) == (2, 2)
        i, state = iterate(symbol_index, state)
        @test (i, state) == (3, 3)

   end
end

#A = reshape(1:24, 2,3,4)
#Aindices = IndicesArray(A, .1:.1:.2, 1//10:1//10:3//10, ["a", "b", "c", "d"])

#= TODO
@testset "axes(A, [d])" begin
    @test @inferred(axes(A)) == (.1:.1:.2, 1//10:1//10:3//10, ["a", "b", "c", "d"])
    @test axes(A, 1) == .1:.1:.2
    @test axes(A, 2) == 1//10:1//10:3//10
    @test axes(A, 3) == ["a", "b", "c", "d"]
    @test @inferred(axes(Ainds)) == axes(Aplain)
    @test axes(Ainds, 1) == axes(Aplain, 1)
    @test axes(Ainds, 2) == axes(Aplain, 2)
    @test axes(Ainds, 3) == axes(Aplain, 3)
end

@testset "filteraxes" begin
    @test @inferred(typeof(filteraxes(allunique, A))) == typeof(axes(A))
    @test @inferred(typeof(filteraxes(allunique, namedaxes(Anamed)))) == typeof(namedaxes(Anamed))
    @test @inferred(length(filteraxes(allunique, A))) == ndims(A)
    @test @inferred(length(filteraxes(i -> length(i) == length(axes(A,1)), A))) == 1

    # No axes should be equal to Zach Efron, nor could they be.
    @test @inferred(filteraxes(i->i == "Zach Efron", A)) == nothing
    @test @inferred(filteraxes(i->i == "Zach Efron", Anamed)) == nothing

    @test_throws no_axes_error("bad test") filteraxes(allunique, "bad test")
end

@testset "findaxes" begin
    @test @inferred(typeof(findaxes(allunique, A))) == NTuple{ndims(A),Int}
    @test @inferred(typeof(findaxes(allunique, Anamed))) == NTuple{ndims(Anamed),Symbol}

    @test @inferred(length(findaxes(allunique, A))) == ndims(A)
    @test @inferred(length(findaxes(i -> length(i) == length(axes(A,1)), A))) == (1,)
    @test @inferred(length(findaxes(i -> length(i) == length(axes(Anamed,1)), Anamed))) == (dimnames(Anamed, 1),)

    # No axes should be equal to Zach Efron, nor could they be.
    @test @inferred(findaxes(i->i == "Zach Efron", A)) == nothing
    @test @inferred(findaxes(i->i == "Zach Efron", Anamed)) == nothing

    @test_throws no_axes_error("bad test") findaxes(allunique, "bad test")
end

=#
