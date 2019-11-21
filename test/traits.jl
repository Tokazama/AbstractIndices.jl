
@testset "Traits" begin
    A = rand(5,4,3)
    Aoneto = IndicesArray(A);

    r1 = range(.1, stop = .2, length=5)
    r2 = ["a", "b", "c", "d"]
    r3 = 2:4

    ind1 = asindex(r1)
    ind2 = asindex(r2)
    ind3 = asindex(r3)

    named_ind1 = OneToIndex{:a}(ind1)
    named_ind2 = OneToIndex{:b}(ind2)
    named_ind3 = OneToIndex{:c}(ind3)

    #map(asindex, (r1, r2, r3), axes(A))
    Aindices = IndicesArray(A, r1, r2, r3);
    Anamed = IndicesArray(Aindices, a = r1, b = r2, c = r3);

    # indexnames,
    # unname,
    @testset "filteraxes" begin
        @test filteraxes(i -> isequal(length(i), 4), A) == (Base.OneTo(4),)
        @test filteraxes(i -> isequal(length(i), 4), Aindices) == (ind2,)
        @test filteraxes(i -> isequal(length(i), 4), Anamed) == (OneToIndex{:b}(ind2),)
    end
    @testset "findaxes" begin
        @test findaxes(i -> isequal(length(i), 3), A) == (3,)
        @test findaxes(i -> isequal(length(i), 3), Aindices) == (3,)
        @test findaxes(i -> isequal(length(i), 3), Anamed) == (3,)
    end

    @testset "to_dims" begin
        @test to_dims(A, 2) == 2
        @test to_dims(Aindices, 2) == 2
        @test to_dims(Anamed, 2) == 2
        @test to_dims(Anamed, :a) == 1
        @test to_dims(Anamed, (1, 2)) == (1, 2)
        @test to_dims(Anamed, (:a, :b)) == (1, 2)
        @test to_dims(Anamed, :) == (1, 2, 3)
        @test to_dims(Aindices, 1) == 1
        @test to_dims(Aindices, :a) == 0
        @test to_dims(Anamed, :d) == 0
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
        @test reduceaxes(Anamed, 2) == (OneToIndex{:a}(ind1), reduceaxis(OneToIndex{:b}(ind2)), OneToIndex{:c}(ind3))
        @test reduceaxes(Anamed, :b) == (OneToIndex{:a}(ind1), reduceaxis(OneToIndex{:b}(ind2)), OneToIndex{:c}(ind3))
        @test reduceaxes(Anamed, (1, 2)) == (reduceaxis(OneToIndex{:a}(ind1)), reduceaxis(OneToIndex{:b}(ind2)), OneToIndex{:c}(ind3))
        @test reduceaxes(Anamed, (:a, :b)) == (reduceaxis(OneToIndex{:a}(ind1)), reduceaxis(OneToIndex{:b}(ind2)), OneToIndex{:c}(ind3))
    end

    # TODO named_axes
    @testset "named_axes" begin
        @test named_axes(Aindices) == (OneToIndex{:dim_1}(ind1),
                                      OneToIndex{:dim_2}(ind2),
                                      OneToIndex{:dim_3}(ind3))
        @test named_axes(Anamed) == (named_ind1, named_ind2, named_ind3)
        @test unnamed_axes(Anamed) == axes(Aindices)
        @test has_indexnames(Anamed) == true
        @test has_indexnames(Aindices) == false
        @test unname((a=1,b=2)) == (1, 2)
        @test indexnames((a=1, b=2)) == (:a, :b)
    end

    @testset "Range interface" begin
        a = [1, 2, 3]
        r = 1:3
        mr = StepMRange(1,1,4)

        @testset "first" begin
            @testset "can_grow_first" begin
                @test @inferred(can_grow_first(a)) == true
                @test @inferred(can_grow_first(r)) == false
                @test @inferred(can_grow_first(mr)) == true
            end

            @testset "set_first!" begin
                @test @inferred(set_first!(a, 2)) == [2, 2, 3]
                @test_throws MethodError set_first!(r, 2)
            end
        end

        @testset "last" begin
            @testset "can_grow_last" begin
                @test @inferred(can_grow_last(a)) == true
                @test @inferred(can_grow_last(r)) == false
                @test @inferred(can_grow_last(mr)) == true
            end

            @testset "set_last!" begin
                @test @inferred(set_last!(a, 2)) == [2, 2, 2]
                @test_throws MethodError set_last!(r, 2)
            end
        end

        @testset "step" begin
            @testset "has_step" begin
                @test @inferred(has_step(a)) == false
                @test @inferred(has_step(r)) == true
                @test @inferred(has_step(mr)) == true
            end

            @testset "can_set_step" begin
                @test @inferred(can_set_step(a)) == false
                @test @inferred(can_set_step(r)) == false
            end

            @testset "set_last!" begin
                @test_throws MethodError set_step!(r, 2)
                set_step!(mr, 2)
                @test @inferred(step(mr)) == 2
            end
        end
    end
end
