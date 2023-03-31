function edit_boundary(R₀::DataRegion)

    # get simplification percentages and their corresponding tolerances
    @time slider_range, tol_range = get_tolerances_slider_values(R₀)

    nH = length(R₀.H)
    n₀ = get_npts(R₀)
    perim₀ = @sprintf "%1.2e" perim(R₀)
    label = R₀.name * " | $nH Holes | $n₀ pts | 0 % del pts | Perim: $perim₀"
    simp_methods = ["Radius test", "Area test"]
    # create two copies of the region
    R = copy_region(R₀)
    Rcopy = copy_region(R)
    # observable for smoothing tolerance
    default_stol = 1e-4
    smooth_tol = Observable(default_stol)
    string_tol = @sprintf "%1.1e" smooth_tol[]
    # dictionary of initial contour points
    DC₀ = Dict(0 => bnd2obsp(R₀.E))
    if ~isempty(R₀.H)
        for k in keys(R₀.H)
            DC₀[k] = bnd2obsp(R₀.H[k])
        end
    end
    # dictionary of simplified contour points
    DCρ = Dict(0 => bnd2obsp(R.E))
    if ~isempty(R.H)
        for k in keys(R.H)
            DCρ[k] = bnd2obsp(R.H[k])
        end
    end
    # figure layout
    fig = Figure()
    ax = region_window(fig, label, 5)
    # draw initial contour
    for k in keys(DC₀)
        lines!(DC₀[k], color=:blue)
    end
    # draw simplified contour
    for k in keys(DCρ)
        lines!(DCρ[k], color=:red)
    end
    # draw dropmenu
    simp_menu = Menu(fig[2, 1], options=simp_methods)
    # slider
    sl = Slider(fig[2, 3],
        range=slider_range,
        startvalue=first(slider_range)
    )
    # label for slider
    Label(fig[2, 2], "Simplify")
    # label for smoothing tolerance
    Label(fig[2, 4], "Smooth tol")
    # draw textbox 
    tb = Textbox(fig[2, 5],
        placeholder=string_tol,
        validator=Float64,
        tellwidth=false
    )
    # draw buttoms
    bt_smooth = Button(fig[2, 6], label="Smooth")
    bt_undo = Button(fig[2, 7], label="Undo")
    bt_save = Button(fig[2, 8], label="Save")
    # show figure
    display(fig)
    # change method on menu selection
    on(simp_menu.selection) do s
        met = s
    end
    # Press R to reset view
    on(events(fig).keyboardbutton) do event
        if event.action in (Keyboard.press, Keyboard.repeat)
            event.key == Keyboard.r && reset_limits!(ax)
        end
        return false
    end
    # change smoothing tolerance value by the supplied value in textbox
    on(tb.stored_string) do var
        smooth_tol[] = parse(Float64, var)
    end
    # undo the approximation when clicking the button undo
    on(bt_undo.clicks) do var
        # set slider value to start value
        set_close_to!(sl, last(slider_range))
        # update region and figure
        R.E = R₀.E
        Rcopy.E = R.E
        DCρ[0][] = p2fp(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                R.H[k] = R₀.H[k]
                Rcopy.H[k] = R.H[k]
                DCρ[k][] = p2fp(R.H[k])
            end
        end
        ax.xlabel = label
    end
    # save region on click the buttom save
    on(bt_save.clicks) do var
        ask_save_region(R)
    end
    # polygon smoothing on clicking the button smooth
    on(bt_smooth.clicks) do var
        # update copy of the last region
        Rcopy.E = R.E
        if ~isempty(R.H)
            for k in keys(R.H)
                Rcopy.H[k] = R.H[k]
            end
        end
        # perimeter minimization
        min_perimeter!(Rcopy, R, smooth_tol[])
        # get number of points of the smoothed contour 
        n = get_npts(R)
        # percentage of deleted points
        new_per = round(100(1 - n / n₀), digits=1)
        # perimeter of the smoothed contour 
        perims = @sprintf "%1.2e" perim(R)
        # update labels
        ax.xlabel = R₀.name *
                    " | $nH Holes | $n of $n₀ pts | $(new_per) % del pts " *
                    " | Perim: $perim₀ to $perims"
        # update figure
        DCρ[0][] = p2fp(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                DCρ[k][] = p2fp(R.H[k])
            end
        end
        # update copy of the last region
        Rcopy.E = R.E
        if ~isempty(R.H)
            for k in keys(R.H)
                Rcopy.H[k] = R.H[k]
            end
        end
    end
    # move therehold slider for polygon simplification        	
    lift(sl.value) do per
        # get simplification therehold
        idx = findfirst(x -> x == per, slider_range)
        simp_tol = tol_range[idx]
        stol = @sprintf "%1.2e" simp_tol
        # simplification
        del_pts!(radiusine, Rcopy, R, simp_tol)
        # get number of points
        n = get_npts(R)
        # percentage of deleted points
        new_per = round(100(1 - n / n₀), digits=1)
        # perimeter of the simplified contour 
        perims = @sprintf "%1.2e" perim(R)
        # update labels
        ax.xlabel = R₀.name *
                    " | $nH Holes | $n of $n₀ pts | $(new_per) % del pts " *
                    " | Perim: $perim₀ to $perims"
        # update figure
        DCρ[0][] = p2fp(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                DCρ[k][] = p2fp(R.H[k])
            end
        end
    end
end