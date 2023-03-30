using EditBoundary
using Test

@testset "geometry" begin

    @test 2 == 2
    v = [5.0;-1.0]
    @test J₂(v) == [v[2]; -v[1]]
    @test length(v) == length(J₂(v)) == 2
    @test_throws BoundsError J₂([1.0])

end
