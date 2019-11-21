
using Base.Sort
using AbstractIndices: UnkownOrder, Unordered

@testset "order" begin
    x = 1:10
    y = 10:-2:1
    z = [1.5, 1.7, 3.3]
    a = [1, 3, 2]

    @testset "order" begin
        @test @inferred(order(x)) == Forward
        @test @inferred(order(y)) == UnkownOrder
        @test @inferred(order(z)) == UnkownOrder
        @test @inferred(order(a)) == UnkownOrder
    end


    # Can't infer type because order not necessarily known at compile time on
    # these. Only gurantee is that it won't be UnkownOrder
    @testset "findorder" begin
        @test findorder(x) == Forward
        @test findorder(y) == Reverse
        @test findorder(z) == Forward
        @test findorder(a) == Unordered
    end

    @testset "isbefore" begin
        @test @inferred(isbefore(2, 3, x)) == true
        @test @inferred(isbefore(3, 2, x)) == false
        @test @inferred(isbefore(1:2, 3:4)) == true
        @test @inferred(isbefore(3:4, 1:2)) == false
        @test @inferred(isbefore(2:-1:1, 4:-1:3)) == true
        @test @inferred(isbefore(4:-1:3, 2:-1:1)) == false
    end

    @testset "isafter" begin
        @test @inferred(isafter(2, 3, x)) == false
        @test @inferred(isafter(3, 2, x)) == true
        @test @inferred(isafter(1:2, 3:4)) == true
        @test @inferred(isafter(3:4, 1:2)) == false
        @test @inferred(isafter(2:-1:1, 4:-1:3)) == true
        @test @inferred(isafter(4:-1:3, 2:-1:1)) == false
    end

    @testset "isforward" begin
        @test @inferred(isforward(x)) == true
        @test @inferred(isforward(y)) == false
        @test @inferred(isforward(z)) == true
        @test @inferred(isforward(a)) == false
    end

    @testset "isreverse" begin
        @test @inferred(isreverse(x)) == false
        @test @inferred(isreverse(y)) == true
        @test @inferred(isreverse(z)) == false
        @test @inferred(isreverse(a)) == false
    end

    @testset "isordered" begin
        @test @inferred(isordered(x)) == true
        @test @inferred(isordered(y)) == true
        @test @inferred(isordered(z)) == true
        @test @inferred(isordered(a)) == false
    end

    @testset "iswithin" begin
        for (xo,yo,x,y) in ((Forward, Forward, 2:3, 1:10)
                      (Reverse, Reverse, 3:-1:2, 10:-1:1),
                      (Forward, Reverse, 2:3, 10:-1:1),
                      (Reverse, Forward, 3:-1:2, 1:10))
        @test @inferred(iswithin(x,y)) == true
        @test @inferred(iswithin(xo,yo,x,y)) == true
        @test @inferred(iswithin(yo,xo,y,x)) == false
    end

    @testset "iscontiguous" begin
        @test @inferred(iscontiguous(1:3, 3:4)) == true
        @test @inferred(iscontiguous(3:-1:1, 3:4)) == true
        @test @inferred(iscontiguous(3:-1:1, 4:-1:3)) == true
        @test @inferred(iscontiguous(1:3, 4:-1:3)) == true
        @test @inferred(iscontiguous(1:3, 2:4)) == false
    end

    @testset "gtmax" begin
        @test @inferred(gtmax(1:10, 1:11)) == false
        @test @inferred(gtmax(1:11, 1:10)) == true
    end

    @testset "ltmax" begin
        @test @inferred(ltmax(1:10, 1:11)) == true
        @test @inferred(ltmax(1:11, 1:10)) == false
    end

    @testset "eqmax" begin
        @test @inferred(eqmax(1:10, 3:10)) == true
        @test @inferred(eqmax(1:11, 1:10)) == false
    end

    @testset "gtmin" begin
        @test @inferred(gtmin(1:10, 3:11)) == false
        @test @inferred(gtmin(3:11, 1:10)) == true
    end

    @testset "ltmin" begin
        @test @inferred(gtmin(1:10, 3:11)) == true
        @test @inferred(gtmin(3:11, 1:10)) == false
    end

    @testset "eqmin" begin
        @test @inferred(eqmin(3:10, 3:11)) == true
        @test @inferred(eqmin(3:11, 2:10)) == false
    end

    @testset "groupmax" begin
        @test @inferred(groupmax(1:10, [1,4, 20], 3.0:-1.0:1.0)) == 20
    end

    @testset "groupmin" begin
        @test @inferred(groupmin(1:10, [1,4, 20], 3.0:-1.0:1.0)) == 1
    end

    @testset "min_of_groupmax" begin
    end

    @testset "max_of_groupmin" begin
    end

    @testset "getbefore" begin
        @test @inferred(getbefore(1:10, 5)) == 1:4
        @test @inferred(getbefore(1.25:.5:10, 5)) == 1.25:0.5:4.75
    end

    @testset "getafter" begin
        @test @inferred(getafter(1:10, 5)) == 6:10
        @test @inferred(getbefore(1.25:.5:10, 5)) == 5.25:0.5:9.75
    end

    @testset "getwithin" begin
    end

    @testset "findclosest" begin
        @test @inferred(findclosest(1, z)) == 1
        @test @inferred(findclosest(1.55, z)) == 1
        @test @inferred(findclosest(1.67, z)) == 2
    end

    @testset "nexttype" begin
        @test nexttype("a") == "b"
        @test nexttype(:a) == :b
        @test nexttype(1) == 2
        @test nexttype(1.0) == nextfloat(1.0)
        @test nexttype("") == ""
    end

    @testset "prevtype" begin
        @test prevtype("b") == "a"
        @test prevtype(:b) == :a
        @test prevtype(1) == 2
        @test prevtype(nextfloat(1.0)) == prevfloat(nextfloat(1.0))
        @test prevtype("") == ""
    end
end
