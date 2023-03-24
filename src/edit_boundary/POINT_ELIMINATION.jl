	"""
	remove!(v,i)
	"""
	function remove!(v::Union{Vector{Float64},Vector{Int64}}, i::Int64)
	    v[i:end-1] = v[i+1:end]
	end

	"""
	shift(i,n)
	"""
	function shift(i::Int64,n::Int64)::Int64 
	    j = i % n
	    (i ≤ 0) && (j+=n)
	    iszero(j) && (j=n)
	    return j
	end

	"""
	areas(P,Q,R)
	"""
	areas(P::Vector{Float64}, Q::Vector{Float64}, R::Vector{Float64}) = 0.5abs(α(P,Q,R))

	"""
	areasine(P,Q,R)
	"""
	function areasine(P::Vector{Float64},Q::Vector{Float64},R::Vector{Float64})
	    as  = get_cos(P,Q,R)
        as  = √(1.0-as*as)
        as *= α(P,Q,R) 
        as < 0 && (as *= -1)
        return as
	end

	"""
	radiusine(P,Q,R)
	"""
	function radiusine(P::Vector{Float64},Q::Vector{Float64},R::Vector{Float64})
	    s = get_cos(P,Q,R)
        s = √(1.0-s*s)
        a = norm(P-Q)
        b = norm(Q-R)
        c = norm(P-R)
        return s*a*b*c/(a+b+c)
	end

	"""
	carnot(P,Q,R)
	"""
	carnot(P::Vector{Float64},Q::Vector{Float64},R::Vector{Float64}) =
	get_cos(P,Q,R) + get_cos(Q,R,P) + get_cos(R,P,Q) - 1

	"""
	del_pts(method, Ω, tol)
	"""
	function del_pts(method::Function, Ω::Matrix{Float64}, tol::Number)

		n  = size(Ω,1)
	    ᾱ  = 0.0
	    jₘᵢₙ  = 0
	    μₘᵢₙ  = Inf
	    μvec  = zeros(n)
	    list  = collect(1:n)

	    for i = 1:n
	        i₋₁ = isone(i) ? n : i-1
	        i₊₁ = i == n ? 1 : i+1
            # update area sum
            ᾱ += abs(α(Ω,i₋₁,i,i₊₁))
            # triangle measure
            μvec[i] = method(Ω[i₋₁,:],Ω[i,:],Ω[i₊₁,:])
            # update smallest measure
	        μvec[i] < μₘᵢₙ && (μₘᵢₙ = μvec[i]; jₘᵢₙ = i)
	    end
	    ᾱ /= 2n
	    ᾱ *= tol

	    while μₘᵢₙ < ᾱ && n > 3

	        j₋₂ = shift(jₘᵢₙ-2,n)
	        j₋₁ = shift(jₘᵢₙ-1,n)
	        j₊₁ = shift(jₘᵢₙ+1,n)
	        j₊₂ = shift(jₘᵢₙ+2,n)
	        i₋₂ = list[j₋₂]
	        i₋₁ = list[j₋₁]
	        i₊₁ = list[j₊₁]
	        i₊₂ = list[j₊₂]

            μvec[j₋₁] = method(Ω[i₋₂,:],Ω[i₋₁,:],Ω[i₊₁,:])
            μvec[j₊₁] = method(Ω[i₋₁,:],Ω[i₊₁,:],Ω[i₊₂,:])

	        n -= 1
	        remove!(μvec,jₘᵢₙ)
	        remove!(list,jₘᵢₙ)
	        μₘᵢₙ, jₘᵢₙ = findmin(μvec[1:n])
	    end
	    idx = list[1:n]
	    return Ω[idx,:]
	end


	"""
	del_pts!(method, R, tol)
	"""
	function del_pts!(method::Function, R::DataRegion, tol::Number)
		R.E = del_pts(method, R.E, tol)
		if ~isempty(R.H)
			for Hₖ in values(R.H)
				Hₖ = del_pts(method, Hₖ, tol)
			end
		end
	end

	"""
	del_pts!(method, R₀, R, tol)
	"""
	function del_pts!(method::Function, R₀::DataRegion, R::DataRegion, tol::Number)
		R.E = del_pts(method, R₀.E, tol)
		if ~isempty(R.H)
			for k in keys(R.H)
				R.H[k] = del_pts(method, R₀.H[k], tol)
			end
		end
	end


	"""
	del_pts!(plt, tab, αplt₀, μplt, R₀, R, infovec, tolarea)
	"""
	function del_pts!( 
					plt::PlotlyJS.SyncPlot,
					tab::PlotlyJS.SyncPlot,
					αplt₀::PlotlyJS.SyncPlot, 
					μplt::PlotlyJS.SyncPlot, 
					R₀::DataRegion,
					R::DataRegion,
					infovec::Vector{String},
					tol::Number
	        		)

		nH   = length(R.H)
		met  = "Del Pts"
		str  = 	" | ENTER to update the tolerance | R reset view | "
        sn   = string(get_npts(R))
        sdel =  "0 del pts of "*sn 
        list_methods = ["visvalingam", "areasine", "rRsine", "r/R"]
		# create a copy of the region
		Rcopy = copy_region(R)
		# get tolerance
	    tol  = Observable(tol)
	    # dictionaries of the boundary points
      	DC₀  = Dict(0 => bnd2obsp(R₀.E))
      	DCρ  = Dict(0 => bnd2obsp(R.E) )
      	if ~isempty(R₀.H)
      		for k in keys(R₀.H)
      			DC₀[k] = bnd2obsp(R₀.H[k])
      		end
      	end
      	if ~isempty(R.H)
      		for k in keys(R.H)
      			DCρ[k] = bnd2obsp(R.H[k])
      		end
      	end		
	    # figure layout
	    fig = Figure()
	    ax  = region_window(fig,met*str*sdel,5)
	    # draw contours
	    for k in keys(DC₀)
	    	lines!(DC₀[k], color = :blue)
	    end
	    for k in keys(DCρ)
	    	lines!(DCρ[k], color = :red)
	    end
	   	# draw dropmenu
	    delmenu = Menu(fig[2,1], options = list_methods)
	    # draw text
	    Label(fig[2, 2], "0.1 ≤ tol ≤ 20", textsize = 15)
	    # draw textbox
	    stol = @sprintf "%1.1e" tol[]
	    tb = Textbox(fig[2,3], 
	             placeholder = stol,
	             validator   = Float64, 
	             tellwidth   = false
	            )
	    # draw buttoms
	    bta = Button(fig[2,4], label = "Apply")
	    btu = Button(fig[2,5], label = "Undo")
	    # show figure
	    display(fig)
	    # change method on menu selection
	    on(delmenu.selection) do s
	    	met = s
	    end 
	    # change tolerance value by the supplied value in textbox
	    on(tb.stored_string) do s
	        tol[] = parse(Float64, s)
	    end
	    # polygon approximation on clicking the button apply
	    on(bta.clicks) do n
	    	nnew = get_npts(R)
	    	# point elimination
	    	if met == "visvalingam"
	    		del_pts!(areas, Rcopy, R, tol[])
	    	elseif met == "areasine"
				del_pts!(areasine, Rcopy, R, tol[])
	    	elseif met == "rRsine"
	        	del_pts!(radiusine, Rcopy, R, tol[])
	    	elseif met == "r/R"
	    		del_pts!(carnot, Rcopy, R, tol[])
	    	end
	    	nnew -= get_npts(R)
	    	snew  = string(nnew)
	        # update figure
      		DCρ[0][] = p2fp(R.E)
	        if ~isempty(R.H)
          		for k in keys(R.H)
          			DCρ[k][] = p2fp(R.H[k])
          		end 
      		end
      		ax.xlabel = str*snew*" del pts of "*sn
      		# update table and area plot
      		R.name = @sprintf " %1.1e" tol[]
			R.name = met*R.name
      		αvec = triangle_areas_sorted(R)
      		labels, newinfovec = basic_region_info(R)
    		update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
    							labels, infovec, newinfovec, αvec)
    		folding(R)
    		R.name = R₀.name
	    end
	    # undo the approximation when clicking the button undo
	    on(btu.clicks) do n 
	    	# update region and figure
	    	R.E = Rcopy.E
	        DCρ[0][] = p2fp(R.E)
	        if ~isempty(R.H)
          		for k in keys(R.H)
          			R.H[k] = Rcopy.H[k]
          			DCρ[k][] = p2fp(R.H[k])
          		end 
      		end
			ax.xlabel = str*"0 del pts of "*sn
      		# update table and area plot
      		R₁ = copy_region(R)
      		del_pts!(areasine, R₁, 0.01)
      		αvec = triangle_areas_sorted(R₁)
      		labels, newinfovec = basic_region_info(R)
    		update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
    							labels, infovec, newinfovec, αvec)
	    end
	    # Press R to reset view
	    on(events(fig).keyboardbutton) do event
	    	if  event.action in (Keyboard.press, Keyboard.repeat)
            	event.key == Keyboard.r && reset_limits!(ax)
        	end
        	return false
        end     	
	end
