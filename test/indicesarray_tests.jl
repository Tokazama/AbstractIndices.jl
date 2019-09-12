
@testset "IndicesArray" begin

    Aplain = reshape(1:24, 2,3,4)
    Ainds = IndicesArray(Aplain)
    A = @inferred(IndicesArray(Aplain,
                               .1:.1:.2,
                               1//10:1//10:3//10,
                               ["a", "b", "c", "d"]))

end
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

@testset "axestype(A, [i])" begin
    @test @inferred(axestype(A, 1)) == typeof(.1:.1:.2)
    @test @inferred(axestype(A, 2)) == typeof(1//10:1//10:3//10)
    @test @inferred(axestype(A, 3)) == typeof(["a", "b", "c", "d"])
end

@testset "axeseltype" begin
    @test @inferred(axeseltype(A, 1)) == Float64
    @test @inferred(axeseltype(A, 2)) == Rational{Int64}
    @test @inferred(axeseltype(A, 3)) == String
end

@test Axis{:x}(1:3) == Axis{:x}(Base.OneTo(3))
@test hash(Axis{:col}(1)) == hash(Axis{:col}(1.0))
@test hash(Axis{:row}()) != hash(Axis{:col}())
@test hash(Axis{:x}(1:3)) == hash(Axis{:x}(Base.OneTo(3)))

@test Axis{:row}(2:7)[4] == 5
@test eltype(Axis{:row}(1.0:1.0:3.0)) == Float64
@test size(Axis{:row}(2:7)) === (6,)
T = A[AxisArrays.Axis{:x}]
@test T[end] == 0.2

@test length(Axis{:col}(-1:2)) === 4


