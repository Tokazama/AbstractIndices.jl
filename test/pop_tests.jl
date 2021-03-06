
@testset "pop" begin
    x = Index{:a}(UnitMRange(1, 10), UnitMRange(1, 10))
    y = Index{:a}(UnitMRange(2, 10), UnitMRange(2, 10))
    z = Index{:a}(UnitMRange(1, 9), UnitMRange(1, 9))
    @test popfirst(x) == y
    @test pop(x) == z

    popfirst!(x)
    @test x == y

    x = Index{:a}(UnitMRange(1, 10), UnitMRange(1, 10))
    pop!(x)
    @test x == z

    x = IArray(collect(1:10))
    y = IArray(collect(2:10))
    z = IArray(collect(1:9))

    @test popfirst(x) == y
    @test pop(x) == z

    popfirst!(x)
    @test x == y

    x = IArray(collect(1:10))
    pop!(x)
    @test x == z
end
