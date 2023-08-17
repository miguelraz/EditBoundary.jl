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