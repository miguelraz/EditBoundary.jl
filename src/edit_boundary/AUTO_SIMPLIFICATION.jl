
	"""
	auto_simplification(Ω,tolsmt,tolcol,tolrad)

	Automatic mode for polygon simplification.
	Subroutine for simple connected polygons
	"""
	function auto_simp( Ω₀::Matrix{Float64}, 
						tolsmt::Float64,
						tolarea::Float64
						)

		Ω = copy(Ω₀)
    	# check if the polygon is a digital contour
    	checkint = sum(isinteger.(Ω)) == prod(size(Ω))
		# iterative point elimination by ϵ-test
		Ω = del_pts(areasine, Ω, 0.1) 
		# smooth polygonal curve by minimizing its perimeter
		Ω .= min_perimeter(Ω, tolsmt)
		# iterative point elimination by ϵ-test
		# use 0.1 without noise and 0.4 with noise
		Ω = del_pts(areasine, Ω, tolarea)
		# rounding
		checkint && ( Ω .= round.(Ω) )
		return Ω
	end

	"""
	auto_simp!(R₀,R,tolsmt,tolarea)

	Automatic mode for polygon simplification.
	Subroutine for polygonal regions.

		1. delete points by ϵ-test
		2. polygon smoothing 
		3. delete points by ϵ-test
		4. rounding for digital curves
		
	INPUT:

	- R₀  	  data structure of the original region
	- R  	  data structure of the approximate region
	- tolsmt  smoothing level 
	- tolauto tolerance for automatic mode

	OUTPUT: the data structure R is overwritten
	"""
	function auto_simp!(R₀::DataRegion,
						R::DataRegion, 
						tolsmt::Float64,
						tolarea::Float64
						)
		R.E = auto_simp(R₀.E,tolsmt,tolarea)
		if ~isempty(R.H)
			for k in keys(R₀.H)
				R.H[k] = auto_simp(R₀.H[k],tolsmt,tolarea)
			end
		end
	end 


	"""
	auto_simp!( plt, tab, αplt₀, μplt, R₀, R, infovec, tolsmt, tolarea)
	"""
	function auto_simp!( 
					plt::PlotlyJS.SyncPlot,
					tab::PlotlyJS.SyncPlot,
					αplt₀::PlotlyJS.SyncPlot, 
					μplt::PlotlyJS.SyncPlot, 
					R₀::DataRegion,
					R::DataRegion,
					infovec::Vector{String},
					tolsmt::Number,
					tolarea::Number
	        		)

		nH   = length(R.H)
	    sn   = string(get_npts(R))
		str  = 	"Auto Mode | ENTER to update the tolerance | "*
            	"R reset view | "
        sdel =  "0 del pts of "*sn 
		Rcopy = copy_region(R)
	    # initialize dictionaries of the boundary points
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
	    # set tolerances
    	tola  = Observable(tolarea)
    	tols  = Observable(tolsmt)
	    # figure layout
	    fig = Figure()
	    ax  = region_window(fig,str*sdel,8)
	    # draw contours
	    for k in keys(DC₀)
	    	lines!(DC₀[k], color = :blue)
	    end
	    for k in keys(DCρ)
	    	lines!(DCρ[k], color = :red)
	    end
	    # draw buttons
	    btd = Button(fig[2,1], label = "Default")
	    btn = Button(fig[2,2], label = "Default (noise)")
	    # draw text
	    Label(fig[2, 3], "tol smooth", textsize = 12)
	    # draw textbox
	    stols = @sprintf "%1.1e" tols[]
	    tbs = Textbox(fig[2,4], 
	             placeholder = stols,
	             validator   = Float64, 
	             tellwidth   = false
	            )
	    # draw text
	    Label(fig[2, 5], "tol del", textsize = 12)
	    # draw textbox
	    stola = @sprintf "%1.1e" tola[]
	    tba = Textbox(fig[2,6], 
	             placeholder = stola,
	             validator   = Float64, 
	             tellwidth   = false
	            )

	    # draw buttons
	    bts = Button(fig[2,7], label = "Apply")
	    btu = Button(fig[2,8], label = "Undo")
	    # show figure
	    display(fig)
	    # change the tolerance value by the supplied value in textbox
	   	on(tbs.stored_string) do s
	        tols[] = parse(Float64, s)
	    end
	    on(tba.stored_string) do s
	        tola[] = parse(Float64, s)
	    end
	    # set default tolerances on clicking the button default 
	    on(btd.clicks) do n
	    	tols[] = 1e-5
	    	tola[] = 0.1
	    end 
	    on(btn.clicks) do n
	    	tols[] = 1e-4
	    	tola[] = 3.0
	    end 
	    # approximate the curve when clicking the button apply
	    on(bts.clicks) do n
	    	nnew  = get_npts(R)
	    	auto_simp!(Rcopy, R, tols[], tola[])
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
			R.name = "auto"
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
      		ax.xlabel = str*sdel
      		# update table and area plot
      		αvec = triangle_areas_sorted(R)
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