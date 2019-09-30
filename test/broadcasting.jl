@testset "Binary broadcasting operations (.+)" begin
    a = IndicesArray(ones(3), :a)

    @testset "standard case" begin
        @test a .+ a == 2ones(3)
        @test dimnames(a .+ a) == (:a,)

        @test a .+ a.+ a == 3ones(3)
        @test dimnames(a .+ a .+ a) == (:a,)
    end

    @testset "partially named dims" begin
        x = IndicesArray(ones(3, 5), (:x, nothing))
        y = IndicesArray(ones(3, 5), (nothing, :y))

        lhs = x .+ y
        rhs = y .+ x
        @test dimnames(lhs) == (:x, :y) == dimnames(rhs)
        @test lhs == 2ones(3, 5) == rhs
    end

    #=
    @testset "Dimension disagreement" begin
        @test_throws DimensionMismatch .+(
            IndicesArray(zeros(3, 3, 3, 3), (:a, :b, :c, :d)),
            IndicesArray(ones(3, 3, 3, 3), (:w, :x, :y, :z))
        )
    end
    =#

    @testset "named and unnamed" begin
        lhs_sum = .+(
            IndicesArray(zeros(3, 3, 3, 3), (:a,:b,:c,:d)),
            ones(3, 3, 3, 3)
        )
        @test lhs_sum == ones(3, 3, 3, 3)
        @test dimnames(lhs_sum) == (:a, :b, :c, :d)


        rhs_sum = .+(
            zeros(3, 3, 3, 3),
            IndicesArray(ones(3, 3, 3, 3), (:w, :x, :y, :z))
        )
        @test rhs_sum == ones(3, 3, 3, 3)
        @test dimnames(rhs_sum) == (:w, :x, :y, :z)
    end

    @testset "broadcasting" begin
        v = IndicesArray(zeros(3,), :time)
        m = IndicesArray(ones(3, 3), (:time, :value))
        s = 0

        @test v .+ m == ones(3, 3) == m .+ v
        @test s .+ m == ones(3, 3) == m .+ s
        @test s .+ v .+ m == ones(3, 3) == m .+ s .+ v

        @test dimnames(v .+ m) == (:time, :value) == dimnames(m .+ v)
        @test dimnames(s .+ m) == (:time, :value) == dimnames(m .+ s)
        @test dimnames(s .+ v .+ m) == (:time, :value) == dimnames(m .+ s .+ v)
    end

    #= TODO figure out how to write this for IndicesArray constructors
    @testset "Mixed array types" begin
        casts = (
            IndicesArray{(:foo, :bar)},  # Named Matrix
            x->IndicesArray{(:foo,)}(x[:, 1]),  # Named Vector
            x->IndicesArray{(:foo, :bar)}(x[:, 1:1]),  # Named Single Column Matrix
            identity, # Matrix
            x->x[:, 1], # Vector
            x->x[:, 1:1], # Single Column Matrix
            first, # Scalar
         )
        for (T1, T2, T3) in Iterators.product(casts, casts, casts)
            all(isequal(identity), (T1, T2, T3)) && continue
            !any(isequal(IndicesArray), (T1, T2, T3, (:foo, :bar))) && continue

            total = T1(ones(3, 6)) .+ T2(2ones(3, 6)) .+ T3(3ones(3, 6))
            @test total == 6ones(3, 6)
            @test names(total) == (:foo, :bar)
        end
    end
    =#

    @testset "Regression test again #8b" begin
        # https://github.com/invenia/NamedDims.jl/issues/8#issuecomment-490124369
        a = IndicesArray(ones(10,20,30), (:x,:y,:z))
        @test a .+ ones(1,20) == 2ones(10,20,30)
        @test dimnames(a .+ ones(1,20)) == (:x, :y, :z)
    end

end
#=

@testset "Competing Wrappers" begin
    nda = IndicesArray(ones(4), :foo)
    ta = TrackedArray(5*ones(4))
    ndt = NamedDimsArray(TrackedArray(5*ones(4)), :foo)

    arrays = (nda, ta, ndt)
    @testset "$a .- $b" for (a, b) in Iterators.product(arrays, arrays)
        a === b && continue
        @test typeof(nda .- ta) <: NamedDimsArray
        @test typeof(parent(nda .- ta)) <: TrackedArray
    end
end
=#
