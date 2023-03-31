using EditBoundary
using Test

@testset "EditBoundary" begin
    @testset "Geometry" begin
        @testset "Area" begin
            @testset "J2" begin
                v = [5.0; -1.0]
                @test J₂(v) == [v[2]; -v[1]]
                @test length(v) == length(J₂(v)) == 2
                @test_throws BoundsError J₂([1.0])
            end

            @testset "α" begin
                P = [2.0; 10.1]
                Q = [5.0; 15.0]
                R = [20.1; -1.0]
                @test α(P, Q, R) == (Q - P)'J₂(R - P)
                @test_throws MethodError J₂([2.0, 1.0, 0.0], [0.1, 0.1, 0.0], [0.0, 0.1, 0.3])
            end
        end
    end
end



