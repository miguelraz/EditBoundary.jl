
	"""
	min_perimeter(xᵢₙᵢ, x₀, p₀, tolsmt, itmax, itfmin)
	"""
	function min_perimeter( xᵢₙᵢ::Vector{Float64}, 
							x₀::Vector{Float64}, 
						 	p₀::Float64, tolsmt::Float64, 
						 	itmax::Int64, itfmin::Int64
						 	)::Vector{Float64}

		opc = Optim.Options(f_tol = 1e-8,
		                    g_tol = 1e-3,
							iterations = itmax,
							outer_iterations = itfmin, 
		                    extended_trace = true);
		inner_optimizer = ConjugateGradient()

		# bounds for boundary neigborhood radius
		lower = x₀ .- tolsmt
		upper = x₀ .+ tolsmt
		# optimization
		optim_data = Optim.optimize(Optim.only_fg!(fg!), 
									lower, upper, xᵢₙᵢ,
								  	Fminbox(inner_optimizer), opc)

		return Optim.minimizer(optim_data)
 	end


	"""	
	min_perimeter(Ω,tolsmt)	
	"""
	function min_perimeter(Ω::Matrix{Float64}, tolsmt::Float64)::Matrix{Float64}

		itmax  = 50
		itfmin = 5

		# perimeter
		p₀ = perim(Ω)
		# boundary neighborhood radius
		tolsmt *= p₀
		# rearrage initial contour
		x₀ = vec(Ω)
		# pertubatation of initial contour
		xᵢₙᵢ = [rand(LinRange(xᵢ-tolsmt,xᵢ+tolsmt,20)[2:end-1]) for xᵢ in x₀]
		# optimization
		xₒₚₜ = min_perimeter(xᵢₙᵢ, x₀, p₀, tolsmt, itmax, itfmin)
		# reshape 1D vector into two-column matrix
		Ω  = reshape(xₒₚₜ,length(xₒₚₜ) ÷ 2,2)
		return Ω
	end


	"""
	min_perimeter!(R₀,R,tol)
	"""
	function min_perimeter!(R₀::DataRegion, R::DataRegion, tolsmt::Float64)

        R.E = min_perimeter(R₀.E,tolsmt)
        if  ~isempty(R.H)
      		for k in keys(R.H)
      			R.H[k] = min_perimeter(R₀.H[k],tolsmt)
      		end 
  		end
	end


	"""
	min_perimeter!( plt, tab, αplt₀, μplt, R₀, R, infovec, tol)
	"""
	function min_perimeter!( 
					plt::PlotlyJS.SyncPlot,
					tab::PlotlyJS.SyncPlot,
					αplt₀::PlotlyJS.SyncPlot, 
					μplt::PlotlyJS.SyncPlot, 
					R₀::DataRegion,
					R::DataRegion,
					infovec::Vector{String},
					tol::Number
	        		)

		# test for digital curve
		checkint = sum(isinteger.(R.E)) == prod(size(R.E))

		str  = 	"Smoothing | "*
				"ENTER to update the tolerance | "*
            	"R reset view | "
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
	    ax  = region_window(fig,str,4)
	    # draw contours
	    for k in keys(DC₀)
	    	lines!(DC₀[k], color = :blue)
	    end
	    for k in keys(DCρ)
	    	lines!(DCρ[k], color = :red)
	    end
	    # draw text
	    Label(fig[2, 1], "tol", textsize = 15)
	    # draw textbox
	    stol = @sprintf "%1.1e" tol[]
	    tb = Textbox(fig[2,2], 
	             placeholder = stol,
	             validator   = Float64, 
	             tellwidth   = false
	            )
	    # draw buttoms
	    bta = Button(fig[2,3], label = "Apply")
	    btu = Button(fig[2,4], label = "Undo")
	    # show figure
	    display(fig)
	    # change tolerance value by the supplied value in textbox
	    on(tb.stored_string) do s
	        tol[] = parse(Float64, s)
	    end
	    # polygon approximation on clicking the button apply
	    on(bta.clicks) do n
	    	# smoothing
	    	min_perimeter!(Rcopy, R, tol[])
	    	# rounding for digital curves
	    	# also delete repeated points
			#=
			if checkint 
				R.E .= round.(R.E)
				R.E  = del_repts(R.E)
				if ~isempty(R.H)
          			for k in keys(R.H)
          				R.H[k] .= round.(R.H[k])
          				R.H[k]  = del_repts(R.H[k])
          			end
          		end
			end
			=#
	        # update figure
	        DCρ[0][] = p2fp(R.E)
	        if ~isempty(R.H)
          		for k in keys(R.H)
          			DCρ[k][] = p2fp(R.H[k])
          		end 
      		end
      		# update table and area plot
			R.name = @sprintf "smoothing %1.1e" tol[]
			R₁ = copy_region(R)
			del_pts!(areasine, R₁, 0.01)
			αvec = triangle_areas_sorted(R₁)
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