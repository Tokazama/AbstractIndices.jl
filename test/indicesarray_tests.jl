@testset "getindex" begin
    a = IndicesArray([10 20; 30 40])

    @test a[1, 1] == a[y=1, x=1] == a[1, 1] == a[CartesianIndex(1, 1)] == 10
    @test a[y=end, x=end] == a[end, end] == 40

    # Unspecified dims become slices
    @test a[y=1] == a[y=1, x=:] == a[:, 1] == [10; 30]

    @test_broken a[CartesianIndex(1), 1] == a[1, 1]

    @testset "name preservation" begin
        @test names(a[y=1]) == (:x, )
        @test names(a[y=1:1]) == (:x, :y)
    end

    # https://github.com/invenia/NamedDims.jl/issues/8
    @testset "with multiple-wildcards" begin
        a_mw = NamedDimsArray{(:_, :_, :c)}(ones(10, 20, 30));
        @test a_mw[c=2] == ones(10, 20)
        @test names(a_mw[c=2]) == (:_, :_)
    end

    @testset "newaxis" begin
        newaxis = [CartesianIndex()];

        @test size(a[:, newaxis, :]) == (2, 1, 2)

        @test size(a[1, newaxis, 1]) == (1, )

        @test size(a[CartesianIndex(1, 1), newaxis]) == (1, )
        @test a[CartesianIndex(1, 1), newaxis][1] == a[1, 1]
    end
end


@testset "views" begin
    a = NamedDimsArray([10 20; 30 40], (:x, :y))

    @test @view(a[y=1]) == @view(a[y=1, x=:]) == @view(a[:, 1]) == [10; 30]

    @testset "name preservation" begin
        @test names(a[y=1]) == (:x, )
        @test names(a[y=1:1]) == (:x, :y)
    end
end


@testset "setindex!" begin
    @testset "by name" begin
        a = NamedDimsArray([10 20; 30 40], (:x, :y))

        a[x=1, y=1] = 100
        @test a == [100 20; 30 40]

        a[x=1] .= 1000
        @test a == [1000 1000; 30 40]
    end

    @testset "by position" begin
        a = NamedDimsArray([10 20; 30 40], (:x, :y))

        a[1, 1] = 100
        @test a == [100 20; 30 40]

        a[1, :] .= 1000
        @test a == [1000 1000; 30 40]
    end
end


@testset "IndexStyle" begin
    a = NamedDimsArray([10 20; 30 40], (:x, :y))
    @test IndexStyle(typeof(a)) == IndexLinear()

    sparse_a = NamedDimsArray(spzeros(4, 2), (:x, :y))
    @test IndexStyle(typeof(sparse_a)) == IndexCartesian()
end


@testset "length/size/axes" begin
    a = IndicesArray([10 20; 30 40; 50 60], (:x, :y))

    @test length(a) == 6

    @test axes(a) == (1:3, 1:2)
    @test axes(a, :x) == (1:3) == axes(a, 1)

    @test size(a) == (3, 2)
    @test size(a, :x) == 3 == size(a, 1)
end


@testset "similar" begin
    a = NamedDimsArray(ones(10, 20, 30, 40), (:a, :b, :c, :d))

    @testset "content" begin
        b = similar(a)
        @test parent(b) !== parent(a)
        @test eltype(b) == Float64
        @test size(b) == (10, 20 , 30, 40)
        @test names(b) == (:a, :b, :c, :d)
    end
    @testset "eltype" begin
        b = similar(a, Char)
        @test parent(b) !== parent(a)
        @test eltype(b) == Char
        @test size(b) == (10, 20, 30, 40)
        @test names(b) == (:a, :b, :c, :d)
    end
    @testset "size" begin
        b = similar(a, Float64, (15, 25, 35, 45))
        @test parent(b) !== parent(a)
        @test eltype(b) == Float64
        @test size(b) == (15, 25, 35, 45)
        @test names(b) == (:a, :b, :c, :d)
    end
    #=
    @testset "dim names" begin
        b = similar(a, Float64, (:w, :x, :y, :z))
        @test parent(b) !== parent(a)
        @test eltype(b) == Float64
        @test size(b) == (10, 20, 30, 40)
        @test names(b) == (:w, :x, :y, :z)
    end

    @testset "dimensions" begin
        b = similar(a, Float64, (w=11, x=22))
        @test parent(b) !== parent(a)
        @test eltype(b) == Float64
        @test size(b) == (11, 22)
        @test names(b) == (:w, :x)
    end
    =#
end


const a = NamedDimsArray([10 20; 30 40], (:x, :y))
@testset "allocations: wrapper" begin
    @test 0 == @allocated parent(a)
    @test 0 == @allocated axes(a)
    @test 0 == @allocated to_dims(a, (:x, :y))
    # TODO @test 0 == @allocated NamedDims.names(ca)

    #=
    @test 0 == @allocated NamedDimsArray(ca, (:x, :y))
    if VERSION >= v"1.1"
        @test 0 == @allocated NamedDimsArray(ca, (:x, :_))
    else
        @test_broken 0 == @allocated NamedDimsArray(ca, (:x, :_))
    end

    # indexing
    @test 0 == @allocated ca[1,1]
    @test 0 == @allocated ca[1,1] = 55
    if v"1.1-" <= VERSION <= v"1.2-" # tests pass on 1.1, including 1.1.1
        @test 0 == @allocated ca[x=1,y=1]
        @test @allocated(ca[x=1]) == @allocated(ca[1,:])
        @test 0 == @allocated ca[x=1,y=1] = 66
    else
        @test_broken 0 == @allocated ca[x=1,y=1]
        @test_broken @allocated(ca[x=1]) == @allocated(ca[1,:])
        @test_broken 0 == @allocated ca[x=1,y=1] = 66
    end
    =#
end
