
"""
bnd_window(fig,str)
"""
function bnd_window(fig::Figure, str::String)
    return Axis(fig[1, 1],
        xlabel=str,
        xminorticksvisible=true,
        yminorticksvisible=true,
        xminorgridvisible=true,
        yminorgridvisible=true,
        xminorticks=IntervalsBetween(11),
        yminorticks=IntervalsBetween(11),
        xminorgridwidth=1,
        yminorgridwidth=1,
        xgridwidth=1,
        ygridwidth=1,
        xminorgridcolor="gray",
        yminorgridcolor="gray",
        xgridcolor="gray",
        ygridcolor="gray"
    )
end

"""
region_window(fig,str,n)
"""
function region_window(fig::Figure, str::String, n::Int64)
    ax = Axis(fig[1, 1:n],
        xlabel=str,
        xticksvisible=false,
        yticksvisible=false,
        xgridvisible=false,
        ygridvisible=false,
        xticklabelsvisible=false,
        yticklabelsvisible=false,
        xminorticksvisible=false,
        yminorticksvisible=false,
        xminorgridvisible=false,
        yminorgridvisible=false
    )
    ax.aspect = DataAspect()
    hidespines!(ax)
    return ax
end

"""
bnd_dict(R)
"""
function bnd_dict(R::DataRegion)

    nH = length(R.H)
    list = [0]
    Dpts = Dict{Int64,Observable{VecPts}}()
    Dflpts = Dict{Int64,Observable{VecPts}}()
    Dpts[0] = bnd2obs(R.E)
    Dflpts[0] = bnd2obs(R.E[[1, end], :])
    # fill dictionaries of the boundary points
    if nH > 0
        for i = 1:nH
            push!(list, i)
            Dpts[i] = bnd2obs(R.H[i])
            Dflpts[i] = bnd2obs(R.H[i][[1, end], :])
        end
    end
    return Dpts, Dflpts, list
end
