
# TODO cov throws weird arrows on the NamedDims + IndicesArray combo
@testset "math" begin
   @testset "$f" for f in (cor,)
        A = rand(3, 5)
        Aindices = IndicesArray(A, [:one, :two, :three], 2:6)
        Anamed = NamedDimsArray{(:a, :b)}(Aindices)
 
        @testset "matrix input, matrix result" begin
            fnamed = f(Anamed, dims=:a)
            findices = f(Aindices, dims=1)
            fbase = f(A, dims=1)

            @test fnamed == findices == fbase
            fnamed = keys.(axes(fnamed))
            findices = keys.(axes(findices))

            @test fnamed == findices == (2:6, 2:6)

            fnamed = f(Anamed; dims=:b)
            findices = f(Aindices, dims=2)
            fbase = f(A, dims=2)

            @test fnamed == findices == fbase
            fnamed = keys.(axes(fnamed))
            findices = keys.(axes(findices))

            @test fnamed == findices == ([:one, :two, :three], [:one, :two, :three])
        end
        @testset "vector input, scalar result" begin
            A = rand(4)
            Aindices = IndicesArray(A, 2:5)
            Anamed = NamedDimsArray{(:a,)}(Aindices)

            fnamed = f(Anamed)
            findices = f(Aindices)
            fbase = f(A)

            @test f(Aindices) isa Number
            @test fnamed == findices == fbase
        end
    end
end
