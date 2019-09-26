
# TODO cov throws weird arrows on the NamedDims + IndicesArray combo
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
end
