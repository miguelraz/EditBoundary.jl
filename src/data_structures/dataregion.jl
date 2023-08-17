mutable struct DataRegion
    # 2 Column Matrix - exterior frontier
    # Represents the exterior polygon
    E::Matrix{Float64}
    # Dict for any Holes 
    H::Dict{Int64,Matrix{Float64}}
    name::String
end