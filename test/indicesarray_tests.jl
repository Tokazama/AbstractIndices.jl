
@testset "IndicesArray" begin
    Aplain = reshape(1:24, 2,3,4)
    Ainds = IndicesArray(Aplain)
    A = @inferred(IndicesArray(Aplain,
                               .1:.1:.2,
                               1//10:1//10:3//10,
                               ["a", "b", "c", "d"]))

end
