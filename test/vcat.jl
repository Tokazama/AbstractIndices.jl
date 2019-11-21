x = asindex(1:2:10, :x)
y = asindex(1:5, :y)

@testset "vcat" begin
    @testset "vcat_keys" begin
        for (x, y, xykeys, xyvals, xyname, xyindex) in ()
            @test vcat_keys(x, y) == xykeys
            @test vcat_keys(keys(x), y) == xykeys
            @test vcat_keys(x, keys(x)) == xykeys
            @test vcat_keys(keys(x), keys(y)) == xykeys

            @test vcat_values(x, y) == xyvals
            @test vcat_values(values(x), y) == xyvals
            @test vcat_values(x, values(x)) == xyvals
            @test vcat_values(values(x), values(y)) == xyvals

            @test vcat_names(x, y) == xyname
            @test vcat_names(dimnames(x), y) == xyname
            @test vcat_names(x, dimnames(x)) == xyname
            @test vcat_names(dimnames(x), dimnames(y)) == xyname

            @test vcat(x, y) == xyname
        end
    end
end
