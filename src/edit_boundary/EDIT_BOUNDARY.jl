"""
    get_obs_dictionary(R)

    Create a dictionary of observables for the contour
"""
function get_obs_dictionary(R::DataRegion)
    D = Dict(0 => bnd2obsp(R.E))
    if ~isempty(R.H)
        for k in keys(R.H)
            D[k] = bnd2obsp(R.H[k])
        end
    end
    return D
end

"""
    figure_layout(Dobs_ini, Dobs_new, slider_range, methods_labels, info_label, string_tol)

    Layout for the figure: contours, menus, buttoms, textboxs, sliders. 
"""
function figure_layout(Dobs_ini, Dobs_new, slider_range, methods_labels, info_label, string_tol)
    # figure layout
    fig = Figure()
    ax = region_window(fig, info_label, 5)
    # draw initial contour
    for k in keys(Dobs_ini)
        lines!(Dobs_ini[k], color=:blue)
    end
    # draw simplified contour
    for k in keys(Dobs_new)
        lines!(Dobs_new[k], color=:red)
    end
    # draw dropmenu
    simp_menu = Menu(fig[2, 1], options=methods_labels)
    # slider
    sl = Slider(fig[2, 3],
        range=slider_range,
        startvalue=first(slider_range)
    )
    # label for slider
    Label(fig[2, 2], "Simplify")
    # label for the smoothing tolerance
    Label(fig[2, 4], "Smooth tol")
    # draw textbox to change the smoothing tolerance
    tb = Textbox(fig[2, 5],
        placeholder=string_tol,
        validator=Float64,
        tellwidth=false
    )
    #_x = global copy(tb)
    #@show "holi"
    # draw buttoms
    bt_smooth = Button(fig[2, 6], label="Smooth")
    bt_undo = Button(fig[2, 7], label="Undo")
    bt_save = Button(fig[2, 8], label="Save")
    return fig, ax, simp_menu, sl, tb, bt_smooth, bt_undo, bt_save
end

"""
    update_figure!(D, R)

    Update dictionary of observables with the region struct
"""
function update_figure!(D, R)
    D[0][] = p2fp(R.E)
    if ~isempty(R.H)
        for k in keys(R.H)
            D[k][] = p2fp(R.H[k])
        end
    end
end

"""
    update_region!(Rcopy::DataRegion, R::DataRegion)

    Overwrite the copy of the region
"""
function update_region!(Rcopy::DataRegion, R::DataRegion)
    # update copy of the last region
    Rcopy.E = R.E
    if ~isempty(R.H)
        for k in keys(R.H)
            Rcopy.H[k] = R.H[k]
        end
    end
end


"""
    comparison_label(R0, R)

    Compare information of the intial contour and its approximation
"""
function comparison_label(R0::DataRegion, R::DataRegion)
    # number of holes
    nH = length(R0.H)
    # number of points  
    n0 = get_npts(R0) # for the initial region
    n = get_npts(R)   # for the approximation
    # percentage of deleted points
    per_delpts = round(100(1 - n / n0), digits=1)
    # get string for the perimeter
    perim_old = @sprintf "%1.2e" perim(vec(R0.E)) # for the initial region
    perim_new = @sprintf "%1.2e" perim(vec(R.E))  # for the approximation
    # get label
    label = R0.name
    label *= " | $nH Holes | $n of $n0 pts | $(per_delpts) % deleted pts "
    label *= " | perimeter: $(perim_old) to $(perim_new)"
    return label
end

"""
    undo_approx!(R0, Rcopy, R, Dobs_new, ax, sl, slider_range)

    restore approximation to the initial contour
"""
function undo_approx!(R0, Rcopy, R, Dobs, ax, sl, slider_range)
    # set slider value to start value
    set_close_to!(sl, last(slider_range))
    # overwrite regions
    update_region!(R, R0)
    update_region!(Rcopy, R)
    # update observables for the contours
    update_figure!(Dobs, R)
    # update label for region comparison
    ax.xlabel = comparison_label(R0, R)
end

"""
    poly_smoothing!(R0, Rcopy, R, Dobs, ax, smooth_tol)

    Polygon smoothing by perimeter minimization
    The figure is updated.  
"""
function poly_smoothing!(R0, Rcopy, R, Dobs, ax, smooth_tol)
    # update region before smoothing
    update_region!(Rcopy, R)
    # smoothing: perimeter minimization
    min_perimeter!(Rcopy, R, smooth_tol[])
    # update region after smoothing
    update_region!(Rcopy, R)
    # update observables for the contours
    update_figure!(Dobs, R)
    # update label for region comparison
    ax.xlabel = comparison_label(R0, R)
end

"""
    poly_simplify!(R0, Rcopy, R, Dobs, ax, simp_method, slider_range, tol_range, per)

    Polygon simplification by Area or Radius Tests
"""
function poly_simplify!(R0, Rcopy, R, Dobs, ax, simp_method, slider_range, tol_range, per)
    # get simplification therehold
    idx = findfirst(x -> x == per, slider_range)
    simp_tol = tol_range[idx]
    # simplification
    if simp_method[] == "Radius test"
        del_pts!(radiusine, Rcopy, R, simp_tol)
    elseif simp_method[] == "Area test"
        del_pts!(areasine, Rcopy, R, simp_tol)
    end
    # update observables for the contours
    update_figure!(Dobs, R)
    # update label for region comparison
    ax.xlabel = comparison_label(R0, R)
end

"""
    edit_boundary(R0)

    Approximation of polygonal contours by simplification and smoothing
    This is the main routine

    Part of the mesh generator UNAMalla 6
"""
function edit_boundary(R0::DataRegion)
    # create two copies of the region
    R = copy_region(R0)
    Rcopy = copy_region(R)
    # get simplification percentages and their corresponding tolerances
    slider_range, tol_range = get_tolerances_slider_values(R0)
    # get comparison label
    info_label = comparison_label(R0, R)
    # labels for simplification methods
    methods_labels = ["Radius test", "Area test"]
    simp_method = Observable(methods_labels[1])
    # observable for smoothing tolerance
    default_stol = 1e-4
    smooth_tol = Observable(default_stol)
    string_smooth_tol = @sprintf "%1.1e" smooth_tol[]
    # dictionary of observables for points of for 
    Dobs_ini = get_obs_dictionary(R0) # initial contour
    Dobs_new = get_obs_dictionary(R) # approximation 
    # figure layout
    fig, ax, simp_menu, sl, tb, bt_smooth, bt_undo, bt_save =
        figure_layout(Dobs_ini, Dobs_new, slider_range, methods_labels, info_label, string_smooth_tol)
    # show figure
    display(fig)
    # Press R to reset view
    on(events(fig).keyboardbutton) do event
        if event.action in (Keyboard.press, Keyboard.repeat)
            event.key == Keyboard.r && reset_limits!(ax)
        end
        return false
    end
    # change method on menu selection
    on(simp_menu.selection) do s
        simp_method[] = s
    end
    # change smoothing tolerance value by the supplied value in textbox
    on(tb.stored_string) do var
        smooth_tol[] = parse(Float64, var)
    end
    # undo the approximation when clicking the button undo
    on(bt_undo.clicks) do _
        undo_approx!(R0, Rcopy, R, Dobs_new, ax, sl, slider_range)
    end
    # save region on click the buttom save
    on(bt_save.clicks) do _
        ask_save_region(R)
    end
    # polygon smoothing on clicking the button smooth
    on(bt_smooth.clicks) do _
        poly_smoothing!(R0, Rcopy, R, Dobs_new, ax, smooth_tol)
    end
    # move slider for polygon simplification        	
    lift(sl.value) do per
        poly_simplify!(R0, Rcopy, R, Dobs_new, ax, simp_method, slider_range, tol_range, per)
    end
end
