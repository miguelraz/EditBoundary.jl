
"""
edit_bnd3(plt,tab,R,tlabels,infovec,nH₀)

Routine for interactive edition of polygons by mouse clicks
"""
function edit_bnd3(
    R::DataRegion,
    tlabels::Vector{String},
    infovec::Vector{String},
    nH₀::Int64
)

    kₘᵢₙ = 0
    iₘᵢₙ = 0
    nH = length(R.H)
    list = [0]
    # figure layout
    str = " R-Click move pt | " *
          " - delete pt | " *
          " + add pt | " *
          " R reset view | " *
          " S save"
    fig = Figure()
    ax = get_axis(fig, str)
    ax.aspect = DataAspect()
    # initialize dictionaries of indexes 
    Diₘᵢₙ = Dict{Int64,Int64}()
    # initialize dictionaries of distances
    Ddₘᵢₙ = Dict{Int64,Float64}()
    # initialize dictionaries of the boundary points
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
    # draw boundary
    for k in list
        scatterlines!(Dpts[i],
            color=:blue,
            markercolor=:blue,
            marker=:circle,
            markersize=5
        )
        lines!(Dflpts[i], color=:blue)
    end
    # show figure
    display(fig)

    on(events(fig).keyboardbutton) do event

        if event.action in (Keyboard.press, Keyboard.repeat)
            # Press R to reset view
            if event.key == Keyboard.r
                reset_limits!(ax)
                # Press S to save polygon
            elseif event.key == Keyboard.s
                R.E = obs2bnd(Dpts[0])
                if ~isempty(R.H)
                    for k = 1:length(R.H)
                        R.H[k] = obs2bnd(Dpts[k])
                    end
                end
                # TODO Ivan
                #update_plot_regions!(plt,tab,R,tlabels,infovec,nH₀)
                ask_save_region(R)
                # Press + to add a middle point in the nearest segment 
                # to the current mouse position
            elseif event.key == Keyboard.kp_add

                new_point = [mouseposition(ax.scene)]
                pt = new_point[1][1:2]

                empty!(Diₘᵢₙ)
                empty!(Ddₘᵢₙ)

                for k in keys(Dpts)
                    Ω = obs2xy(Dpts[k])
                    nΩ = size(Ω, 1)
                    iₖ = argmin([distseg(Ω[i, :], Ω[i+1, :], pt) for i = 1:nΩ-1])
                    Diₘᵢₙ[k] = iₖ
                    Ddₘᵢₙ[k] = distseg(Ω[iₖ, :], Ω[iₖ+1, :], pt)
                end

                kₘᵢₙ = list[argmin([Ddₘᵢₙ[k] for k in list])]
                iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]

                Ω = obs2xy(Dpts[kₘᵢₙ])
                d₁ = distseg(Ω[end, :], Ω[1, :], pt)
                dₖ = distseg(Ω[iₘᵢₙ, :], Ω[iₘᵢₙ+1, :], pt)
                if d₁ < dₖ
                    ptm = 0.5sum(Ω[[1, end], :]; dims=1)

                    Dpts[kₘᵢₙ][] = [Dpts[kₘᵢₙ][]
                        [ptm]
                    ]
                else
                    ptm = 0.5sum(Ω[iₘᵢₙ:iₘᵢₙ+1, :]; dims=1)

                    Dpts[kₘᵢₙ][] = [Dpts[kₘᵢₙ][][1:iₘᵢₙ]
                        Point2f0[ptm]
                        Dpts[kₘᵢₙ][][iₘᵢₙ+1:end]
                    ]
                end
                # Press - to delete the nearest point to mouse position
            elseif event.key == Keyboard.kp_subtract

                new_point = [mouseposition(ax.scene)]
                pt = new_point[1][1:2]

                empty!(Diₘᵢₙ)
                empty!(Ddₘᵢₙ)

                for k in keys(Dpts)
                    Ω = obs2xy(Dpts[k])
                    nΩ = size(Ω, 1)
                    iₖ = argmin([norm(Ω[i, :] - pt) for i = 1:nΩ])
                    Diₘᵢₙ[k] = iₖ
                    Ddₘᵢₙ[k] = norm(Ω[iₖ, :] - pt)
                end

                kₘᵢₙ = list[argmin([Ddₘᵢₙ[k] for k in list])]
                iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]
                nΩ = length(Dpts[kₘᵢₙ][])

                if isone(iₘᵢₙ)
                    idx = 2:nΩ
                elseif iₘᵢₙ == nΩ
                    idx = 1:nΩ-1
                else
                    idx = [1:iₘᵢₙ-1; iₘᵢₙ+1:nΩ]
                end
                Dpts[kₘᵢₙ][] = Dpts[kₘᵢₙ][][idx]
                Dflpts[kₘᵢₙ][] = [first(Dpts[kₘᵢₙ][]), last(Dpts[kₘᵢₙ][])]
            end
        end
        return false
    end

    on(events(ax.scene).mousebutton, priority=2) do event

        # move point on right click
        if event.button == Mouse.right

            new_point = [mouseposition(ax.scene)]
            pt = new_point[1][1:2]

            if event.action == Mouse.press

                empty!(Diₘᵢₙ)
                empty!(Ddₘᵢₙ)

                for k in keys(Dpts)
                    Ω = obs2xy(Dpts[k])
                    nΩ = size(Ω, 1)
                    iₖ = argmin([norm(Ω[i, :] - pt) for i = 1:nΩ])
                    Diₘᵢₙ[k] = iₖ
                    Ddₘᵢₙ[k] = norm(Ω[iₖ, :] - pt)
                end

                kₘᵢₙ = list[argmin([Ddₘᵢₙ[k] for k in list])]
                iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]

            end

            nΩ = length(Dpts[kₘᵢₙ][])

            if isone(iₘᵢₙ)
                Dpts[kₘᵢₙ][] = [new_point
                    Dpts[kₘᵢₙ][][2:nΩ]
                ]
            elseif iₘᵢₙ == nΩ
                Dpts[kₘᵢₙ][] = [Dpts[kₘᵢₙ][][1:nΩ-1]
                    new_point
                ]
            else
                Dpts[kₘᵢₙ][] = [Dpts[kₘᵢₙ][][1:iₘᵢₙ-1]
                    new_point
                    Dpts[kₘᵢₙ][][iₘᵢₙ+1:nΩ]
                ]
            end
            Dflpts[kₘᵢₙ][] = [first(Dpts[kₘᵢₙ][]), last(Dpts[kₘᵢₙ][])]
            return Consume(true)
        end
        return Consume(false)
    end
    return Dpts
end
