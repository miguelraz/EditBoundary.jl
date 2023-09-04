using EditBoundary
using Test

#=
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
=#

@testset "EditBoundary" begin
    @testset "geometry" begin
        @info "run get_npts test"
        @testset "get_npts" begin 
            # the exterior boundary is a pentagon 
            E = [-1 -2; 1 -2; 2 0; 0 2; -2 0]
            # two holes: one hole is a square, and the other is a triangle
            H = Dict(1 => [-0.5 -1; -0.5 -1.5; 0 -1.5; 0 -1], 2 => [0 0; 0.5 0; 0 0.5])
            # new DataRegion
            R = DataRegion(E,H,"poly3")
            # the sum of points in a pentagon, a square, and a triangle is twelve 
            @test get_npts(R) == 12
            # the triangle is removed
            delete!(H,2)
            # the sum of points in a pentagon and a square is nine 
            @test get_npts(R) == 9
            # the square is removed, so no more holes
            delete!(H,1)
            # now we have only the fivepoints of the pentagon 
            @test get_npts(R) == 5
        end
        @info "get_npts test finish"
    end 
end



