
@testset "math" begin
   @testset "$f" for f in (cor,cov)
        A = rand(3, 5)
        Aindices = IArray(A, ([:one, :two, :three], 2:6))

       @testset "matrix input, matrix result" begin
            findices = f(Aindices, dims=1)
            fbase = f(A, dims=1)

            @test findices == fbase
            findices = keys.(axes(findices))

            @test findices == (2:6, 2:6)

            findices = f(Aindices, dims=2)
            fbase = f(A, dims=2)

            @test findices == fbase
            findices = keys.(axes(findices))

            @test findices == ([:one, :two, :three], [:one, :two, :three])
        end
        @testset "vector input, scalar result" begin
            A = rand(4)
            Aindices = IArray(A, 2:5)

            findices = f(Aindices)
            fbase = f(A)

            @test f(Aindices) isa Number
            @test findices == fbase
        end
    end
end


@testset "+" begin
    a = IArray(ones(3))
    @test +(a) == ones(3)
    @test +(a, a) == 2ones(3)
    @test +(a, a, a) == 3ones(3)
    @test +(a, parent(a)) == 2ones(3)
    @test +(parent(a), a) == 2ones(3)

        #=
        casts = (NamedDimsArray{(:foo, :bar)}, identity)
        for (T1, T2, T3, T4) in Iterators.product(casts, casts, casts, casts)
            all(isequal(identity), (T1, T2, T3, T4)) && continue
            total = T1(ones(3, 6)) + T2(2ones(3, 6)) + T3(3ones(3, 6)) + T4(4ones(3, 6))
            @test total == 10ones(3, 6)
            @test names(total) == (:foo, :bar)
        end
        =#
end

@testset "-" begin
    a = IArray(ones(3))
    @test -(a) == -ones(3)
    @test -(a, a) == -(parent(a), parent(a))
    @test -(a, a, a) == parent(a) - parent(a) - parent(a)
    @test -(a, parent(a)) == -(parent(a), parent(a))
    @test -(parent(a), a) == -(parent(a), parent(a))
end

