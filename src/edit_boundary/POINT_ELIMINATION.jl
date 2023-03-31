function remove!(v::Union{Vector{Float64},Vector{Int64}}, i::Int64)
    v[i:end-1] = v[i+1:end]
end

function shift(i::Int64, n::Int64)::Int64
    j = i % n
    (i ≤ 0) && (j += n)
    iszero(j) && (j = n)
    return j
end


"""
    del_repts(Ω,ltol)

Delete repeated points in a polygon using the length of segments 
"""
function del_repts(Ω::Matrix{Float64}, ltol::Float64)::Matrix{Float64}
    pΩ = 0.0
    nΩ = size(Ω, 1)
    lvec = zeros(nΩ)
    # loop on vertices
    for k = 1:nΩ-1
        dx = Ω[k+1, 1] - Ω[k, 1]
        dy = Ω[k+1, 2] - Ω[k, 2]
        # length of segment
        lvec[k] = √(dx * dx + dy * dy)
        # update perimeter of region
        pΩ += lvec[k]
    end
    dx = Ω[1, 1] - Ω[nΩ, 1]
    dy = Ω[1, 2] - Ω[nΩ, 2]
    lvec[nΩ] = √(dx * dx + dy * dy)
    pΩ += lvec[nΩ]
    # scaling
    lvec ./= pΩ
    # find repeated points
    idrep = findall(x -> x ≤ ltol, lvec)
    # indexes of non-repeated points
    idx = setdiff(1:nΩ, idrep)
    # delete repeated points
    return Ω[idx, :]
end

"""
    del_repts!(R,ltol)

Delete repeated points in a polygon using the length of segments 
"""
function del_repts!(R::DataRegion, ltol::Float64=1e-10)
    # count number of points before point elimination
    n_old = get_npts(R)
    # delete repeated points in the exterior boundary
    R.E = del_repts(R.E, ltol)
    # detect holes
    if ~isempty(R.H)
        # loop on holes
        for k in keys(R.H)
            # delete repeated points in each hole
            R.H[k] = del_repts(R.H[k], ltol)
        end
    end
    # count number of points after point elimination
    n_new = get_npts(R)
    n_diff = n_new - n_old
    n_diff > 0 && display("$n_diff repeated pts deleted")
end

function del_pts(method::Function, Ω::Matrix{Float64}, tol::Number)

    n = size(Ω, 1)
    jₘᵢₙ = 0
    μₘᵢₙ = Inf
    μave = 0
    μvec = zeros(n)
    list = collect(1:n)

    μvec[1] = method(Ω[n, :], Ω[1, :], Ω[2, :])
    μvec[1] < μₘᵢₙ && (μₘᵢₙ = μvec[1];
    jₘᵢₙ = 1)
    μave += μvec[1]
    for i = 2:n-1
        # triangle measure
        μvec[i] = method(Ω[i-1, :], Ω[i, :], Ω[i+1, :])
        # update smallest measure
        μvec[i] < μₘᵢₙ && (μₘᵢₙ = μvec[i];
        jₘᵢₙ = i)
        # update average measure
        μave += μvec[i]
    end
    μvec[n] = method(Ω[n-1, :], Ω[n, :], Ω[1, :])
    μvec[n] < μₘᵢₙ && (μₘᵢₙ = μvec[n];
    jₘᵢₙ = n)
    μave += μvec[n]

    μave /= n
    μave *= tol

    while μₘᵢₙ < μave && n > 3

        j₋₂ = shift(jₘᵢₙ - 2, n)
        j₋₁ = shift(jₘᵢₙ - 1, n)
        j₊₁ = shift(jₘᵢₙ + 1, n)
        j₊₂ = shift(jₘᵢₙ + 2, n)
        i₋₂ = list[j₋₂]
        i₋₁ = list[j₋₁]
        i₊₁ = list[j₊₁]
        i₊₂ = list[j₊₂]

        μvec[j₋₁] = method(Ω[i₋₂, :], Ω[i₋₁, :], Ω[i₊₁, :])
        μvec[j₊₁] = method(Ω[i₋₁, :], Ω[i₊₁, :], Ω[i₊₂, :])

        n -= 1
        remove!(μvec, jₘᵢₙ)
        remove!(list, jₘᵢₙ)
        μₘᵢₙ, jₘᵢₙ = findmin(μvec[1:n])
    end
    idx = list[1:n]
    return Ω[idx, :]
end

function del_pts!(method::Function, R::DataRegion, tol::Number)
    R.E = del_pts(method, R.E, tol)
    if ~isempty(R.H)
        for Hₖ in values(R.H)
            Hₖ = del_pts(method, Hₖ, tol)
        end
    end
end

function del_pts!(method::Function, R₀::DataRegion, R::DataRegion, tol::Number)
    R.E = del_pts(method, R₀.E, tol)
    if ~isempty(R.H)
        for k in keys(R.H)
            R.H[k] = del_pts(method, R₀.H[k], tol)
        end
    end
end

function del_pts!(R₀::DataRegion,
    slider_range::AbstractVector,
    tol_range::AbstractVector
)

    nH = length(R₀.H)
    n₀ = get_npts(R₀)
    p₀ = @sprintf "%1.2e" perim(R₀)
    α₀ = @sprintf "%1.2e" α(R₀)
    label = R₀.name * " | $n₀ pts | 0 % del pts | Perim: $p₀"
    simp_methods = ["weighted radius test", "weighted area test"]
    # create a copy of the region
    R = copy_region(R₀)
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
    delmenu = Menu(fig[2, 1], options=simp_methods)
    # slider
    sl = Slider(fig[2, 2],
        range=slider_range,
        startvalue=first(slider_range)
    )
    # 
    Label(fig[2, 3], "% Deleted Points")
    # draw buttoms
    btu = Button(fig[2, 4], label="Undo")
    bts = Button(fig[2, 5], label="Save")
    # show figure
    display(fig)
    # change method on menu selection
    on(delmenu.selection) do s
        met = s
    end
    # Press R to reset view
    on(events(fig).keyboardbutton) do event
        if event.action in (Keyboard.press, Keyboard.repeat)
            event.key == Keyboard.r && reset_limits!(ax)
        end
        return false
    end
    # undo the approximation when clicking the button undo
    on(btu.clicks) do n
        # set slider value to start value
        set_close_to!(sl, last(slider_range))
        # update region and figure
        R.E = R₀.E
        DCρ[0][] = p2fp(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                R.H[k] = R₀.H[k]
                DCρ[k][] = p2fp(R.H[k])
            end
        end
        ax.xlabel = label
    end
    # save region on click the buttom save
    on(bts.clicks) do n
        ask_save_region(R)
    end
    # move therehold slider for polygon simplification        	
    lift(sl.value) do per
        # get simplification therehold
        idx = findfirst(x -> x == per, slider_range)
        tol = tol_range[idx]
        stol = @sprintf "%1.2e" tol
        # simplification
        del_pts!(radiusine, R₀, R, tol)
        # measures of the simplified contour 
        pᵢ = @sprintf "%1.2e" perim(R)
        αᵢ = @sprintf "%1.2e" α(R)
        # percentage of deleted points
        n = get_npts(R)
        p = round(100(1 - n / n₀), digits=1)
        # update labels
        ax.xlabel = R₀.name *
                    " | $n of $n₀ pts | $p % del pts " *
                    " | Perim: Ini $p₀ Simp $pᵢ"
        # update figure
        DCρ[0][] = p2fp(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                DCρ[k][] = p2fp(R.H[k])
            end
        end
    end

end