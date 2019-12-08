@testset "matmul" begin
    x = rand(4, 3)
    y = rand(3, 7)
    z = rand(7)

    xi = IArray(x, (mrange(2.0, 5.0), mrange(2.0, 4.0)))
    yi = IArray(y)
    zi = IArray(z)

    for (x_test, y_test) in ((xi, yi),
                             (yi, zi),
                             (x, yi),
                             (xi, y),
                             (y, zi),
                             (yi, z),
                             (z, zi'),
                             (zi, z')
                            )
        @testset "$(summary(x_test)) & $(summary(y_test))" begin
            out = *(x_test, y_test)
            if x_test isa IndicesArray
                if y_test isa IndicesArray
                    @test out == *(parent(x_test), parent(y_test))
                else
                    @test out == *(parent(x_test), y_test)
                end
            else
                @test out == *(x_test, parent(y_test))
            end
            if out isa AbstractArray
                @test isa(out, IndicesArray) == true
            end
        end
    end
end
