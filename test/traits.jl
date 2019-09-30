
@testset "Traits" begin
    A = rand(5,4,3)
    Aoneto = IndicesArray(A);

    r1 = range(.1, stop = .2, length=5)
    r2 = ["a", "b", "c", "d"]
    r3 = 2:4

    ind1 = asindex(r1)
    ind2 = asindex(r2)
    ind3 = asindex(r3)

    named_ind1 = NamedIndex{:a}(ind1)
    named_ind2 = NamedIndex{:b}(ind2)
    named_ind3 = NamedIndex{:c}(ind3)

    #map(asindex, (r1, r2, r3), axes(A))
    Aindices = IndicesArray(A, r1, r2, r3);
    Anamed = IndicesArray(Aindices, a = r1, b = r2, c = r3);

    # dimnames,
    # unname,
    @testset "filteraxes" begin
        @test filteraxes(i -> isequal(length(i), 4), A) == (Base.OneTo(4),)
        @test filteraxes(i -> isequal(length(i), 4), Aindices) == (ind2,)
        @test filteraxes(i -> isequal(length(i), 4), Anamed) == (NamedIndex{:b}(ind2),)
    end
    @testset "findaxes" begin
        @test findaxes(i -> isequal(length(i), 3), A) == (3,)
        @test findaxes(i -> isequal(length(i), 3), Aindices) == (3,)
        @test findaxes(i -> isequal(length(i), 3), Anamed) == (3,)
    end

    @testset "finddims" begin
        @test finddims(A, dims=2) == 2
        @test finddims(Aindices, dims=2) == 2
        @test finddims(Aindices, 2) == 2
        @test finddims(Anamed, 2) == 2
        @test finddims(Anamed, :a) == 1
        @test finddims(Anamed, (1, 2)) == (1, 2)
        @test finddims(Anamed, (:a, :b)) == (1, 2)
        @test finddims(Anamed, :) == (1, 2, 3)
        @test finddims(Aindices, 1) == 1
        @test finddims(Aindices, :a) == 0
        @test finddims(Anamed, :d) == 0
    end

    @testset "mapaxes" begin
        @test mapaxes(length, Aindices) == (length(named_ind1),
                                            length(named_ind2),
                                            length(named_ind3))
    end

    @testset "dropaxes" begin
        @test dropaxes(Anamed, dims=:b) == (named_ind1, named_ind3)
    end

    @testset "permuteaxes" begin
        @test permuteaxes(Anamed, (:c, :b, :a)) == (named_ind3, named_ind2, named_ind1)
    end

    @testset "reduceaxes" begin
        @test reduceaxes(A, dims=2) == (Base.OneTo(5), 1, Base.OneTo(3))
        @test reduceaxes(Aindices, dims=2) == (ind1, reduceaxis(ind2), ind3)
        @test reduceaxes(Anamed, 2) == (NamedIndex{:a}(ind1), reduceaxis(NamedIndex{:b}(ind2)), NamedIndex{:c}(ind3))
        @test reduceaxes(Anamed, :b) == (NamedIndex{:a}(ind1), reduceaxis(NamedIndex{:b}(ind2)), NamedIndex{:c}(ind3))
        @test reduceaxes(Anamed, (1, 2)) == (reduceaxis(NamedIndex{:a}(ind1)), reduceaxis(NamedIndex{:b}(ind2)), NamedIndex{:c}(ind3))
        @test reduceaxes(Anamed, (:a, :b)) == (reduceaxis(NamedIndex{:a}(ind1)), reduceaxis(NamedIndex{:b}(ind2)), NamedIndex{:c}(ind3))
    end

    # TODO namedaxes
    @testset "namedaxes" begin
        @test namedaxes(Aindices) == (NamedIndex{:dim_1}(ind1),
                                      NamedIndex{:dim_2}(ind2),
                                      NamedIndex{:dim_3}(ind3))
        @test namedaxes(Anamed) == (named_ind1, named_ind2, named_ind3)
        @test unnamedaxes(Anamed) == axes(Aindices)
        @test hasdimnames(Anamed) == true
        @test hasdimnames(Aindices) == false
        @test unname((a=1,b=2)) == (1, 2)
        @test dimnames((a=1, b=2)) == (:a, :b)
    end
end
