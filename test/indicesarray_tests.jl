@testset "getindex" begin
    a = IndicesArray([10 20; 30 40])

    @test nda[1, 1] == nda[y=1, x=1] == nda[1, 1] == nda[CartesianIndex(1, 1)] == 10
    @test nda[y=end, x=end] == nda[end, end] == 40

    # Unspecified dims become slices
    @test nda[y=1] == nda[y=1, x=:] == nda[:, 1] == [10; 30]

    @test_broken nda[CartesianIndex(1), 1] == nda[1, 1]

    @testset "name preservation" begin
        @test names(nda[y=1]) == (:x, )
        @test names(nda[y=1:1]) == (:x, :y)
    end

    # https://github.com/invenia/NamedDims.jl/issues/8
    @testset "with multiple-wildcards" begin
        nda_mw = NamedDimsArray{(:_, :_, :c)}(ones(10, 20, 30));
        @test nda_mw[c=2] == ones(10, 20)
        @test names(nda_mw[c=2]) == (:_, :_)
    end

    @testset "newaxis" begin
        newaxis = [CartesianIndex()];

        @test size(nda[:, newaxis, :]) == (2, 1, 2)

        @test size(nda[1, newaxis, 1]) == (1, )

        @test size(nda[CartesianIndex(1, 1), newaxis]) == (1, )
        @test nda[CartesianIndex(1, 1), newaxis][1] == nda[1, 1]
    end
end


@testset "views" begin
    nda = NamedDimsArray([10 20; 30 40], (:x, :y))

    @test @view(nda[y=1]) == @view(nda[y=1, x=:]) == @view(nda[:, 1]) == [10; 30]

    @testset "name preservation" begin
        @test names(nda[y=1]) == (:x, )
        @test names(nda[y=1:1]) == (:x, :y)
    end
end


@testset "setindex!" begin
    @testset "by name" begin
        nda = NamedDimsArray([10 20; 30 40], (:x, :y))

        nda[x=1, y=1] = 100
        @test nda == [100 20; 30 40]

        nda[x=1] .= 1000
        @test nda == [1000 1000; 30 40]
    end

    @testset "by position" begin
        nda = NamedDimsArray([10 20; 30 40], (:x, :y))

        nda[1, 1] = 100
        @test nda == [100 20; 30 40]

        nda[1, :] .= 1000
        @test nda == [1000 1000; 30 40]
    end
end


@testset "IndexStyle" begin
    nda = NamedDimsArray([10 20; 30 40], (:x, :y))
    @test IndexStyle(typeof(nda)) == IndexLinear()

    sparse_nda = NamedDimsArray(spzeros(4, 2), (:x, :y))
    @test IndexStyle(typeof(sparse_nda)) == IndexCartesian()
end


@testset "length/size/axes" begin
    nda = NamedDimsArray([10 20; 30 40; 50 60], (:x, :y))

    @test length(nda) == 6

    @test axes(nda) == (1:3, 1:2)
    @test axes(nda, :x) == (1:3) == axes(nda, 1)

    @test size(nda) == (3, 2)
    @test size(nda, :x) == 3 == size(nda, 1)
end


@testset "similar" begin
    nda = NamedDimsArray{(:a, :b, :c, :d)}(ones(10, 20, 30, 40))

    @testset "content" begin
        ndb = similar(nda)
        @test parent(ndb) !== parent(nda)
        @test eltype(ndb) == Float64
        @test size(ndb) == (10, 20 , 30, 40)
        @test names(ndb) == (:a, :b, :c, :d)
    end
    @testset "eltype" begin
        ndb = similar(nda, Char)
        @test parent(ndb) !== parent(nda)
        @test eltype(ndb) == Char
        @test size(ndb) == (10, 20, 30, 40)
        @test names(ndb) == (:a, :b, :c, :d)
    end
    @testset "size" begin
        ndb = similar(nda, Float64, (15, 25, 35, 45))
        @test parent(ndb) !== parent(nda)
        @test eltype(ndb) == Float64
        @test size(ndb) == (15, 25, 35, 45)
        @test names(ndb) == (:a, :b, :c, :d)
    end
    @testset "dim names" begin
        ndb = similar(nda, Float64, (:w, :x, :y, :z))
        @test parent(ndb) !== parent(nda)
        @test eltype(ndb) == Float64
        @test size(ndb) == (10, 20, 30, 40)
        @test names(ndb) == (:w, :x, :y, :z)
    end

    @testset "dimensions" begin
        ndb = similar(nda, Float64, (w=11, x=22))
        @test parent(ndb) !== parent(nda)
        @test eltype(ndb) == Float64
        @test size(ndb) == (11, 22)
        @test names(ndb) == (:w, :x)
    end
end


const cnda = NamedDimsArray([10 20; 30 40], (:x, :y))
@testset "allocations: wrapper" begin
    @test 0 == @allocated parent(cnda)
    @test 0 == @allocated NamedDims.names(cnda)

    @test 0 == @allocated NamedDimsArray(cnda, (:x, :y))
    if VERSION >= v"1.1"
        @test 0 == @allocated NamedDimsArray(cnda, (:x, :_))
    else
        @test_broken 0 == @allocated NamedDimsArray(cnda, (:x, :_))
    end

    # indexing
    @test 0 == @allocated cnda[1,1]
    @test 0 == @allocated cnda[1,1] = 55
    if v"1.1-" <= VERSION <= v"1.2-" # tests pass on 1.1, including 1.1.1
        @test 0 == @allocated cnda[x=1,y=1]
        @test @allocated(cnda[x=1]) == @allocated(cnda[1,:])
        @test 0 == @allocated cnda[x=1,y=1] = 66
    else
        @test_broken 0 == @allocated cnda[x=1,y=1]
        @test_broken @allocated(cnda[x=1]) == @allocated(cnda[1,:])
        @test_broken 0 == @allocated cnda[x=1,y=1] = 66
    end
end
