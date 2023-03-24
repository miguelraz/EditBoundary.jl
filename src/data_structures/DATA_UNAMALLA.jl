
    mutable struct DataRegion
        E::Matrix{Float64}
        H::Dict{Int64,Array{Float64}}
        idcuts::Matrix{Int64}
        idreg::Int64
        name::String
    end

    Base.@kwdef mutable struct editbnd_threholds  
        tolsmt::Number  = 3e-4 # smoothing tolerance
        tolarea::Number = 0.1  # average area tolerance
        tolauto::Number = 3.0  # tolerance for automatic mode
    end

    (~ @isdefined threholds ) && ( threholds = editbnd_threholds() )

