function remove!(v::AbstractVector{T}, i::Int64) where T
    v[i:end-1] = @views v[i+1:end]
end

function shift(i::Int64, n::Int64)::Int64
    j = i % n
    (i ≤ 0) && (j += n)
    iszero(j) && (j = n)
    return j
end

function del_pts(method::F, Ω::Matrix{Float64}, tol::Number) where {F}

    n = size(Ω, 1)
    jₘᵢₙ = 0
    μₘᵢₙ = Inf
    μave = 0
    μvec = zeros(n)
    list = collect(1:n)

    μvec[1] = @views method(Ω[n, :], Ω[1, :], Ω[2, :])
    μvec[1] < μₘᵢₙ && (μₘᵢₙ = μvec[1];
    jₘᵢₙ = 1)
    μave += μvec[1]
    for i = 2:n-1
        # triangle measure
        μvec[i] = @views method(Ω[i-1, :], Ω[i, :], Ω[i+1, :])
        # update smallest measure
        μvec[i] < μₘᵢₙ && (μₘᵢₙ = μvec[i];
        jₘᵢₙ = i)
        # update average measure
        μave += μvec[i]
    end
    μvec[n] = @views method(Ω[n-1, :], Ω[n, :], Ω[1, :])
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

        μvec[j₋₁] = @views method(Ω[i₋₂, :], Ω[i₋₁, :], Ω[i₊₁, :])
        μvec[j₊₁] = @views method(Ω[i₋₁, :], Ω[i₊₁, :], Ω[i₊₂, :])

        n -= 1
        remove!(μvec, jₘᵢₙ)
        remove!(list, jₘᵢₙ)
        μₘᵢₙ, jₘᵢₙ = @views findmin(μvec[1:n])
    end
    idx = list[1:n]
    return @views Ω[idx, :]
end


function del_pts!(method::F, R₀::DataRegion, R::DataRegion, tol::Number) where {F}
    R.E = del_pts(method, R₀.E, tol)
    if ~isempty(R.H)
        for k in keys(R.H)
            R.H[k] = del_pts(method, R₀.H[k], tol)
        end
    end
end
#=
function del_pts!(method::F, R::DataRegion, tol::Number) where {F}
    R.E = del_pts(method, R.E, tol)
    if ~isempty(R.H)
        for Hₖ in values(R.H)
            Hₖ = del_pts(method, Hₖ, tol)
        end
    end
end
=#
#=
function del_pts!(R₀::DataRegion,
    slider_range::AbstractVector,
    tol_range::AbstractVector
)

    nH = length(R₀.H)
    n₀ = get_npts(R₀)
    p₀ = @sprintf "%1.2e" perim(vec(R₀.E))
    α₀ = @sprintf "%1.2e" α(R₀.E)
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
=#
