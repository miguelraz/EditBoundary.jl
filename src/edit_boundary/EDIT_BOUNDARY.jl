
	"""
	edit_boundary(plt, tab, αplt₀, μplt, R₀, R, infovec)

	Routine for interactive edition of polygons by mouse clicks
	"""
	function edit_boundary(
				plt::PlotlyJS.SyncPlot,
				tab::PlotlyJS.SyncPlot,
				αplt₀::PlotlyJS.SyncPlot, 
				μplt::PlotlyJS.SyncPlot, 
				R₀::DataRegion,
				R::DataRegion,
				infovec::Vector{String}
				)

		kₘᵢₙ = 0
		iₘᵢₙ = 0
        # figure layout
      	str = 	" R-Click move pt | "*
      			" -/d delete pt | "*
            	" +/a add pt | "*
            	" R reset view | "*
            	" U update"
        fig = Figure()
      	ax  = bnd_window(fig,str)
      	ax.aspect = DataAspect()
        # initialize dictionaries of indexes 
      	Diₘᵢₙ = Dict{Int64,Int64}()
      	# initialize dictionaries of distances
	    Ddₘᵢₙ = Dict{Int64,Float64}()
	    # dictionaries of the boundary points
      	Dpts, Dflpts, list = bnd_dict(R)
      	# draw boundary
      	for k in list
  			scatterlines!(Dpts[k],
                 color=:blue, 
                 markercolor =:red, 
                 marker = :circle, 
                 markersize = 5
                 )
  			lines!(Dflpts[k],color=:blue)
  		end
  		# show figure
    	display(fig)

        on(events(fig).keyboardbutton) do event
        	
            if  event.action in (Keyboard.press, Keyboard.repeat)
            	# Press R to reset view
                if event.key == Keyboard.r 
                	reset_limits!(ax)
                # Press U to update the region
                elseif event.key == Keyboard.u
					R.E = obs2bnd(Dpts[0])
					if ~isempty(R.H)
					    for k = 1:length(R.H)
					        R.H[k] = obs2bnd(Dpts[k])
					    end
					end
					R₁ = copy_region(R)
					del_pts!(areasine, R₁, 0.01)
					αvec = triangle_areas_sorted(R₁)
					labels, newinfovec = basic_region_info(R)
					update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
    							labels, infovec, newinfovec, αvec)
                # Press + to add a middle point in the nearest segment 
		        # to the current mouse position
                elseif event.key in [Keyboard.kp_add, Keyboard.a]

			        newpt = [mouseposition(ax.scene)]
			        pt = newpt[1][1:2]

	            	empty!(Diₘᵢₙ)
	            	empty!(Ddₘᵢₙ)

		            for k in keys(Dpts)
		               Ω  = obs2xy(Dpts[k])
		               nΩ = size(Ω,1)
		               iₖ = argmin([distseg(Ω[i,:],Ω[i+1,:],pt) for i=1:nΩ-1])
		               Diₘᵢₙ[k] = iₖ
		               Ddₘᵢₙ[k] = distseg(Ω[iₖ,:],Ω[iₖ+1,:],pt)
		            end

		            kₘᵢₙ = list[ argmin([ Ddₘᵢₙ[k] for k in list]) ]
		            iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]
			        
			        Ω  = obs2xy(Dpts[kₘᵢₙ])
			        d₁ = distseg(Ω[end,:],Ω[1,:],pt)
			        dₖ = distseg(Ω[iₘᵢₙ,:],Ω[iₘᵢₙ+1,:],pt)
			        if 	d₁ < dₖ
			            ptm = 0.5sum(Ω[[1,end],:];dims=1)

			            Dpts[kₘᵢₙ][] = vcat(Dpts[kₘᵢₙ][], Point2f0[ptm])
			        else
			            ptm = 0.5sum(Ω[iₘᵢₙ:iₘᵢₙ+1,:];dims=1)

			            Dpts[kₘᵢₙ][] = vcat(Dpts[kₘᵢₙ][][1:iₘᵢₙ],
	    								 	Point2f0[ptm],
	    								 	Dpts[kₘᵢₙ][][iₘᵢₙ+1:end] 
	    								 	)
			        end
			    # Press - to delete the nearest point to mouse position
			    elseif event.key in [Keyboard.kp_subtract, Keyboard.d]

			        newpt = [mouseposition(ax.scene)]
			        pt = newpt[1][1:2]

	            	empty!(Diₘᵢₙ)
	            	empty!(Ddₘᵢₙ)

		            for k in keys(Dpts)
		               Ω  = obs2xy(Dpts[k])
		               nΩ = size(Ω,1)
		               iₖ = argmin( [ norm(Ω[i,:]-pt) for i=1:nΩ ] )
		               Diₘᵢₙ[k] = iₖ
		               Ddₘᵢₙ[k] = norm(Ω[iₖ,:]-pt) 
		            end

		            kₘᵢₙ = list[ argmin( [ Ddₘᵢₙ[k] for k in list] ) ]
		            iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]
		            nΩ = length(Dpts[kₘᵢₙ][])

		            if isone(iₘᵢₙ)
		                idx = 2:nΩ
		            elseif iₘᵢₙ == nΩ
		                idx = 1:nΩ-1
		            else
		                idx = [1:iₘᵢₙ-1;iₘᵢₙ+1:nΩ]
		            end
		            Dpts[kₘᵢₙ][] = Dpts[kₘᵢₙ][][idx]
		            Dflpts[kₘᵢₙ][] = [ first(Dpts[kₘᵢₙ][]), last(Dpts[kₘᵢₙ][]) ]
                end
            end
            return false
        end

		on(events(ax.scene).mousebutton, priority = 2) do event

		    # move point on right click
		    if event.button == Mouse.right

			    newpt = [mouseposition(ax.scene)]
			    pt = newpt[1][1:2]

		    	if event.action == Mouse.press

	            	empty!(Diₘᵢₙ)
	            	empty!(Ddₘᵢₙ)

		            for k in keys(Dpts)
		               Ω  = obs2xy(Dpts[k])
		               nΩ = size(Ω,1)
		               iₖ = argmin( [ norm(Ω[i,:]-pt) for i =1:nΩ ] )
		               Diₘᵢₙ[k] = iₖ
		               Ddₘᵢₙ[k] = norm(Ω[iₖ,:]-pt) 
		            end

            		kₘᵢₙ = list[ argmin( [ Ddₘᵢₙ[k] for k in list] ) ]
            		iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]

		    	end

		    	nΩ = length(Dpts[kₘᵢₙ][])

	    		if isone(iₘᵢₙ)
                	Dpts[kₘᵢₙ][] = vcat(newpt, Dpts[kₘᵢₙ][][2:nΩ] )
	            elseif iₘᵢₙ == nΩ
	                Dpts[kₘᵢₙ][] = vcat(Dpts[kₘᵢₙ][][1:nΩ-1], newpt)
	            else
	                Dpts[kₘᵢₙ][] = vcat(Dpts[kₘᵢₙ][][1:iₘᵢₙ-1], newpt,
	                					Dpts[kₘᵢₙ][][iₘᵢₙ+1:nΩ] )
	            end
	            Dflpts[kₘᵢₙ][] = [ first(Dpts[kₘᵢₙ][]), last(Dpts[kₘᵢₙ][]) ]
	            return Consume(true)	                 		    		
		    end		
		    return Consume(false)
		end
		return Dpts
	end

	"""
	edit_boundary(threholds)
	"""
	function edit_boundary(threholds::editbnd_threholds)

		display("Program for approximation of a polygonal region")
		display("Choose a region")
		# labels for menus
		title_menu   = "Edit Boundary Menu"
		labels_menu  = ["Auto"
						"Smoothing"
						"Del Pts"
						"Del Holes"
						"Interaction"
						"Reset"
						"Save"
						"Exit"
						]
		# get tolerances
		tolsmt  = threholds.tolsmt
		tolarea = threholds.tolarea
		# load region
		R₀ = get_region()
		# regions must have at most 50 holes 	
		length(R₀.H) > 50 && remove_holes!(R₀.H)
		# get region info
		labels, infovec = basic_region_info(R₀)
		# create a copy of the region 
		R  = copy_region(R₀)
		R₁ = copy_region(R₀)
		# draw menu
		menu = draw_menu(labels_menu,title_menu)
		# draw comparative plot
		plt  = plot_region(R₀,R)
		# draw comparative table
		tab  = region_table(labels,repeat(infovec,1,2))
		# remove collinear points
		del_pts!(areasine, R₁, 0.01)
		# draw measure plots
		αvec  = triangle_areas_sorted(R₁)
		αplt₀ = plot_measure(αvec,"Area Plot Original")
		αplt  = plot_measure(αvec,"Area Plot Approx")
		μplt  = [αplt₀ αplt]
		relayout!(μplt, template = "plotly_white",
						height = 500,
						showlegend = false,
						hovermode  = false)
		# show menu, plots and tables
		display(menu)
		display(plt)
		display(tab)
		display(μplt)
		# check for self intersections
		folding(R₀)
		# event on menu clicks
		on(menu["click"]) do data 
	    	opc = data["points"][1]["curveNumber"]+1
	    	# automatic mode
    		if 	opc == 1
    			auto_simp!(plt, tab, αplt₀, μplt, R₀, R, infovec, tolsmt, tolarea)
        	# only contour smoothing
    		elseif opc == 2
    			min_perimeter!(plt, tab, αplt₀, μplt, R₀, R, infovec, tolsmt)
    		# only delete points
    		elseif opc == 3
    			del_pts!(plt, tab, αplt₀, μplt, R₀, R, infovec, tolarea)
    		# only delete holes
    		elseif opc == 4
    			if  isempty(R.H)
					display("Nothing to do. The region doesn't have holes")
				else
	    			remove_holes!(plt, tab, αplt₀, μplt, R₀, R, infovec)
	    		end
			# interactive mode
			elseif opc == 5
		        edit_boundary(plt, tab, αplt₀, μplt, R₀, R, infovec)
		    # restart again
    		elseif opc == 6
    			R = copy_region(R₀)
    			update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
    								labels, infovec, infovec, αvec)
        	# save region
    		elseif opc == 7
    			filepath = ask_save_region(R)
		    	save_region_plot(R₀,R,filepath)
    		# quit
    		elseif opc == 8
		        clear_output()
		        display("bye")
    		else
    			display("click again")
    		end
    	end
	end