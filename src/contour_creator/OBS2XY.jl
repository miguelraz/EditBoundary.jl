VecPts = Vector{Point{2,Float32}}
p2f(Ω::Matrix{Float64}) = Point2f0[tuple(Ω[i, :]...) for i = 1:size(Ω, 1)]
p2f1(Ω::Matrix{Float64}) = Point2f0[tuple(Ω[i, :]...) for i in [1, size(Ω, 1)]]
p2fp(Ω::Matrix{Float64}) = Point2f0[tuple(Ω[i, :]...) for i in [1:size(Ω, 1); 1]]

bnd2obs(Ω::Matrix{Float64}) = GLMakie.Node(p2f(Ω))
bnd2obs1(Ω::Matrix{Float64}) = GLMakie.Node(p2f1(Ω))
bnd2obsp(Ω::Matrix{Float64}) = GLMakie.Node(p2fp(Ω))

obs2bnd(pts::Observable{VecPts}) = [pts[][i][j] for i = 1:length(pts[]), j = 1:2]
obs2xy(pts::Observable{VecPts}) = obs2bnd(pts)
obs2xy(pts::VecPts)::Matrix{Float64} = Float64.([pts[i][j] for i = 1:length(pts), j = 1:2])