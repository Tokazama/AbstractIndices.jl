
@testset "math" begin
   @testset "$f" for f in (cor,cov)
        A = rand(3, 5)
        Aindices = IndicesArray(A, a = [:one, :two, :three], b = 2:6)

       @testset "matrix input, matrix result" begin
            findices = f(Aindices, dims=1)
            fnamed = f(Aindices, dims=:a)
            fbase = f(A, dims=1)

            @test fnamed == findices == fbase
            fnamed = keys.(axes(fnamed))
            findices = keys.(axes(findices))

            @test fnamed == findices == (2:6, 2:6)

            fnamed = f(Aindices; dims=:b)
            findices = f(Aindices, dims=2)
            fbase = f(A, dims=2)

            @test fnamed == findices == fbase
            fnamed = keys.(axes(fnamed))
            findices = keys.(axes(findices))

            @test fnamed == findices == ([:one, :two, :three], [:one, :two, :three])
        end
        @testset "vector input, scalar result" begin
            A = rand(4)
            Aindices = IndicesArray(A, a = 2:5)

            findices = f(Aindices)
            fbase = f(A)

            @test f(Aindices) isa Number
            @test findices == fbase
        end
    end

    @testset "matmul" begin
        #=
        @testset "matrix_prod_names" begin
            @test matrix_prod_names((:foo, :bar), (:bar, :buzz)) == (:foo, :buzz)
            @test matrix_prod_names((:foo, :bar), (:_, :buzz)) == (:foo, :buzz)
            @test matrix_prod_names((:foo, :_), (:bar, :buzz)) == (:foo, :buzz)
            @test matrix_prod_names((:foo, :_), (:_, :buzz)) == (:foo, :buzz)
            @test_throws DimensionMismatch matrix_prod_names((:foo, :bar), (:nope, :buzz))

            @test matrix_prod_names((:foo,), (:bar, :buzz)) == (:foo, :buzz)
            @test matrix_prod_names((:foo,), (:_, :buzz)) == (:foo, :buzz)
            # No error case with name mismatch here, as a Vector has "virtual" wildcard second dimension

            @test matrix_prod_names((:foo, :bar), (:bar,)) == (:foo,)
            @test matrix_prod_names((:foo, :bar), (:_, )) == (:foo,)
            @test matrix_prod_names((:foo, :_), (:bar,)) == (:foo,)
            @test matrix_prod_names((:foo, :_), (:_,)) == (:foo,)
            @test_throws DimensionMismatch matrix_prod_names((:foo, :bar), (:nope,))
        end
        =#

        @testset "Matrix-Matrix" begin
            nda = IndicesArray(ones(2, 3), (:a, :b))
            ndb = IndicesArray(ones(3, 2), (:b, :c))

            @testset "standard case" begin
                @test nda * ndb == 3ones(2, 2)
                @test dimnames(nda * ndb) == (:a, :c)

                @test ones(4, 3) * ndb == 3ones(4, 2)
                @test dimnames(ones(4, 3) * ndb) == (nothing, :c)

                @test nda * ones(3, 7) == 3ones(2, 7)
                @test dimnames(nda * ones(3,7)) == (:a, nothing)
            end

            #=
            @testset "Dimension disagreement" begin
                @test_throws DimensionMismatch ndb * nda
            end
            =#
        end

        @testset "mat-vec and vec-mat" begin
            mat = IndicesArray(ones(1, 1), (:a, :b))
            avec = IndicesArray(ones(1), :a)
            bvec = IndicesArray(ones(1), :b)

            @testset "Matrix-Vector" begin
                @test mat * bvec == ones(1)
                @test dimnames(mat * bvec) == (:a,)
            end

            @testset "Vector-Matrix" begin
                @test avec * mat == ones(1, 1)
                @test dimnames(avec * mat) == (:a, :b)
            end
        end

        @testset "Vector-Vector" begin
            v = [1, 2, 3]
            vec = IndicesArray(v, :vec)
#            @test_throws MethodError ndv * ndv
            @test vec' * vec == 14
            @test vec' * vec == adjoint(vec) * v == transpose(vec) * v
            @test vec' * vec == adjoint(v) * vec == transpose(v) * vec
            @test vec * vec' == [1 2 3; 2 4 6; 3 6 9]

#            vec2 = IndicesArray([3, 2, 1], :b)
#            @test_throws DimensionMismatch ndv' * ndv2
        end
    end
end


@testset "+" begin
    a = IndicesArray(ones(3), :a)

    @testset "standard case" begin
        @test +(a) == ones(3)
        @test dimnames(+(a)) == (:a,)

        @test +(a, a) == 2ones(3)
        @test dimnames(+(a, a)) == (:a,)

        @test +(a, a, a) == 3ones(3)
        @test dimnames(+(a, a, a)) == (:a,)
    end

    @testset "partially named dims" begin
        x = IndicesArray(ones(3, 5), (:x, nothing))
        y = IndicesArray(ones(3, 5), (nothing, :y))

        lhs = x + y
        rhs = y + x
        @test dimnames(lhs) == (:x, :y) == dimnames(rhs)
        @test lhs == 2ones(3, 5) == rhs
    end

    #=
    @testset "Dimension disagreement" begin
        @test_throws DimensionMismatch +(
            IndicesArray(zeros(3, 3, 3, 3), (:a, :b, :c, :d)),
            IndicesArray(ones(3, 3, 3, 3), (:w, :x, :y, :z))
        )

        @test_throws DimensionMismatch +(
            IndicesArray(zeros(3,), :time), IndicesArray(ones(3, 3), :time)
        )
    end
    =#

    @testset "Mixed array types" begin
        lhs_sum = +(
            IndicesArray(zeros(3, 3, 3, 3), (:a, :b, :c, :d)),
            ones(3, 3, 3, 3)
        )
        @test lhs_sum == ones(3, 3, 3, 3)
        @test dimnames(lhs_sum) == (:a, :b, :c, :d)


        rhs_sum = +(
            zeros(3, 3, 3, 3),
            IndicesArray(ones(3, 3, 3, 3), (:w, :x, :y, :z))
        )
        @test rhs_sum == ones(3, 3, 3, 3)
        @test dimnames(rhs_sum) == (:w, :x, :y, :z)


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
end
