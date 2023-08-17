    mutable struct DataRegion
        # 2 Column Matrix - exterior frontier
        # Represents the exterior polygon
        E::Matrix{Float64}
        # Dict for any Holes 
        H::Dict{Int64,Matrix{Float64}}
        name::String
    end

    Base.@kwdef mutable struct editbnd_threholds  
        tolsmt::Number  = 3e-4 # smoothing tolerance
        tolarea::Number = 0.1  # average area tolerance
        tolauto::Number = 3.0  # tolerance for automatic mode
    end

    (~ @isdefined threholds ) && ( threholds = editbnd_threholds() )

