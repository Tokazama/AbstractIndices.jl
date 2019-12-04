@testset "reducedims" begin
    A = reshape(Vector(1:16), (4,4))
    Aindices = IndicesArray(A, a = 2:5, b = [:one, :two, :three, :four])

    A1 = reduce(max, A, dims=1)
    A2 = reduce(max, A, dims=2)
    A3 = reduce(max, A, dims=:)

    Aind1 = reduce(max, Aindices, dims=:a)
    Aind2 = reduce(max, Aindices, dims=:b)
    Aind3 = reduce(max, Aindices, dims=:)


    @test A1 == Aind1
    @test A2 == Aind2
    @test A3 == Aind3
end

@testset "Base" begin
    A = [10 20; 31 40]
    Aindices = IndicesArray(A, x = 2:3, y = [:one, :two])

    @testset "$f" for f in (sum, prod, maximum, minimum, extrema)
        @test f(A) == f(Aindices)
        @test f(Aindices; dims=:x) == f(Aindices; dims=1) == f(A; dims=1)

        #@test indexnames(f(Aindices; dims=:x)) == (:x, :y) == indexnames(f(Aindices; dims=1))
    end

    @testset "$f" for f in (cumsum, cumprod, sort)
        @test f(Aindices; dims=:x) == f(Aindices; dims=1) == f(A; dims=1)

        #@test indexnames(f(Aindices; dims=:x)) == (:x, :y) == indexnames(f(Aindices; dims=1))

        @test f([1, 4, 3]) == f(IndicesArray([1, 4, 3], (:vec,)))
#        @test_throws UndefKeywordError f(nda)
#        @test_throws UndefKeywordError f(a)
    end

    #= TODO sort
    @testset "sort!" begin
        A = [1 9; 7 3]
        Anamed = IndicesArray(A, (:x, :y))

        # Vector case
        veca = [1, 9, 7, 3]
        sort!(NamedDimsArray(veca, :vec); order=Base.Reverse)
        @test issorted(veca; order=Base.Reverse)

        # Higher-dim case: `dims` keyword in `sort!` requires Julia v1.1+
        if VERSION > v"1.1-"
            sort!(Anamed, dims=:y)
            @test issorted(a[2, :])
            @test_throws UndefKeywordError sort!(Anamed)

            sort!(Anamed; dims=:x, order=Base.Reverse)
            @test issorted(a[:, 1]; order=Base.Reverse)
        end
    end
    =#

    #= TODO eachslice
    @testset "eachslice" begin
        slices = [[111 121; 211 221], [112 122; 212 222]]
        A = cat(slices...; dims=3)
        Anamed = IndicesArrayArray(A, (:a, :b, :c))

        @test (
            sum(eachslice(Anamed; dims=:c)) ==
            sum(eachslice(Anamed; dims=3)) ==
            sum(eachslice(A; dims=3)) ==
            slices[1] + slices[2]
        )
#        @test_throws ArgumentError eachslice(Anamed; dims=(1, 2))
#        @test_throws ArgumentError eachslice(a; dims=(1, 2))

#        @test_throws UndefKeywordError eachslice(Anamed)
#        @test_throws UndefKeywordError eachslice(A)

        @test (
            indexnames(first(eachslice(Anamed; dims=:b))) ==
            indexnames(first(eachslice(Anamed; dims=2))) ==
            (:a, :c)
        )
    end
    =#

    @testset "mapslices" begin
        A = [10 20; 31 40]
        Anamed = IndicesArray(A, (:x, :y))

        @test (
            mapslices(join, Anamed; dims=:x) ==
            mapslices(join, Anamed; dims=1) ==
            ["1031" "2040"]
        )
        @test (
            mapslices(join, Anamed; dims=:y) ==
            mapslices(join, Anamed; dims=2) ==
            reshape(["1020", "3140"], Val(2))
        )
        @test (
            mapslices(join, Anamed; dims=(:x, :y)) ==
            mapslices(join, Anamed; dims=(1, 2)) ==
            reshape(["10312040"], (1, 1))
        )
#        @test_throws UndefKeywordError mapslices(join, nda)
#        @test_throws UndefKeywordError mapslices(join, a)

        #=@test (
            indexnames(mapslices(join, Anamed; dims=:y)) ==
            indexnames(mapslices(join, Anamed; dims=2)) ==
            (:x, :y)
        )
        =#
    end

    @testset "mapreduce" begin
        A = [10 20; 31 40]
        Aindices = IndicesArray(A, (:x, :y))

        @test mapreduce(isodd, |, Aindices) == true == mapreduce(isodd, |, A)
        @test (mapreduce(isodd, |, Aindices; dims=:x) ==
               mapreduce(isodd, |, Aindices; dims=1) ==
               [true false])
        @test (mapreduce(isodd, |, Aindices; dims=:y) ==
               mapreduce(isodd, |, Aindices; dims=2) ==
               [false true]')
        #=@test (indexnames(mapreduce(isodd, |, Aindices; dims=:y)) ==
               indexnames(mapreduce(isodd, |, Aindices; dims=2)) ==
               (:x, :y))
        =#
    end

    @testset "zero" begin
        A = [10 20; 31 40]
        Aindices = IndicesArray(A, (:x, :y))

        @test zero(Aindices) == [0 0; 0 0] == zero(A)
        #@test indexnames(zero(Aindices)) == (:x, :y)
    end

    @testset "count" begin
        A = [true false; true true]
        Aindices = IndicesArray(A, (:x, :y))

        @test count(Aindices) == count(A) == 3
#        @test_throws ErrorException count(nda; dims=:x)
#        @test_throws ErrorException count(a; dims=1)
    end
end  # Base

@testset "Statistics" begin
    A = [10 20; 30 40]
    Aindices = IndicesArray(A, (:x, :y))
    @testset "$f" for f in (mean, std, var, median)
        @test f(Aindices) == f(A)
        @test f(Aindices; dims=:x) == f(Aindices; dims=1) == f(A; dims=1)

        #@test indexnames(f(Aindices; dims=:x)) == (:x, :y) == indexnames(f(Aindices; dims=1))
    end
end
