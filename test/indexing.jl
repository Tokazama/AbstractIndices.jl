@testset "AbstractIndicesArrays" begin

    A = rand(5,4,3)
    Aoneto = IndicesArray(A);

    r1 = range(.1, stop = .2, length=5)
    r2 = ["a", "b", "c", "d"]
    r3 = 2:4

    ind1 = asindex(r1)
    ind2 = asindex(r2)
    ind3 = asindex(r3)

    Aindices = IndicesArray(A, r1, r2, r3);
    Anamed = IndicesArray(Aindices, (:a, :b, :c));

   # TODO ensure ind3 = 1 is out of bounds error
    @testset "axes(A, [d])" begin
        @test axes(Aindices, 1) == ind1
        @test axes(Aindices, 2) == ind2
        @test axes(Aindices, 3) == ind3

        @test axes(A, 1) == values(axes(Aoneto, 1))
        @test axes(A, 2) == values(axes(Aoneto, 2))
        @test axes(A, 3) == values(axes(Aoneto, 3))
    end

    @testset "Single Indexing" begin
        t1 = getindex(A, 1, 1, 1)
        t2 = getindex(A, 5, 4, 3)

        @test getindex(Aoneto, 1, 1, 1) == t1
        @test getindex(Aindices, r1[1], r2[1], r3[1]) == t1

        # Cartesian indexing bypasses any sort of AbstractIndex
        @test getindex(Aoneto, CartesianIndex(1,1,1)) == t1
        @test getindex(Aindices, CartesianIndex(1,1,1)) == t1

        @test getindex(Aoneto, 5, 4, 3) == t2
        @test getindex(Aindices, r1[5], r2[4], r3[3]) == t2

        # Cartesian indexing bypasses any sort of AbstractIndex
        @test getindex(Aoneto, CartesianIndex(5, 4, 3)) == t2
        @test getindex(Aindices, CartesianIndex(5, 4, 3)) == t2

        @test getindex(Aoneto, 1) == t1
        @test getindex(Aindices, 1) == t1
        @test getindex(Aoneto, 60) == t2
        @test getindex(Aindices, 60) == t2

        @test checkbounds(Bool, Aindices, 61) == false
        @test checkbounds(Bool, Anamed, 61) == false

        @test checkbounds(Bool, Aoneto, 2, 2, 2, 1) == true
        @test checkbounds(Bool, Aindices, r1[2], r2[2], r3[2], 1) == true

        @test checkbounds(Bool, Aoneto, 2, 2, 2, 2) == false
        @test checkbounds(Bool, Aindices, r1[2], r2[2], r3[2], 2) == false

        @test checkbounds(Bool, Aoneto, 1, 1)  == false
        @test checkbounds(Bool, Aindices, r1[1], r2[1])  == false
        @test checkbounds(Bool, Aindices, 1, 12) == false
        @test checkbounds(Bool, Aindices, 5, 12) == false
        @test checkbounds(Bool, Aindices, 1, 13) == false
        @test checkbounds(Bool, Aindices, 6, 12) == false

        @test checkbounds(Bool, Aoneto, 0, 1, 1) == false
        @test checkbounds(Bool, Aoneto, 1, 0, 1) == false
        @test checkbounds(Bool, Aoneto, 1, 1, 0) == false
        @test checkbounds(Bool, Aoneto, 6, 4, 3) == false
        @test checkbounds(Bool, Aoneto, 5, 5, 3) == false
        @test checkbounds(Bool, Aoneto, 5, 4, 4) == false
   end

    @testset "Vector indexing" begin
        @test getindex(Aindices, r1, r2, r3) == getindex(A, 1:5, 1:4, 1:3)
        @test getindex(Aoneto, 1:5, 1:4, 1:3) == getindex(A, 1:5, 1:4, 1:3)

        @test getindex(Aindices, 1:60) == getindex(Aoneto, 1:60) == getindex(A, 1:60)
        @test checkbounds(Bool, A, 2, 2, 2, 1:1) == true  # extra indices
    end

    @testset "NamedDimsExtra" begin

        @testset "filteraxes" begin
            @test filteraxes(allunique, A) == axes(A)
            @test filteraxes(allunique, Anamed) == axes(Anamed)
            @test length(filteraxes(allunique, A)) == ndims(A)
            @test length(filteraxes(i -> length(i) == length(axes(A,1)), A)) == 1
       end

        @testset "findaxes" begin
            @test findaxes(allunique, A) == ntuple(i->i, ndims(A))
            @test findaxes(allunique, Anamed) == ntuple(i->i, ndims(A))

            @test length(findaxes(allunique, A)) == ndims(A)
            @test findaxes(i -> i == axes(A,1), A) == (1,)
            @test findaxes(i -> i == axes(Anamed,1), Anamed) == (1,)
        end
    end
end
