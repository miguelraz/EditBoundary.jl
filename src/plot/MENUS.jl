	"""
	menu_trace(labels)
	"""
	function menu_trace(labels::Vector{String})

	    vtrace = AbstractTrace[]   
	    n = length(labels)
	    for i = 1:n
	        rectᵢ =  PlotlyJS.scatter( 
						x = [i-1, i, i, i-1], 
						y = [0, 0, 0.4, 0.4],
						mode = "lines",
						line_color = "blue",
						line_width = 1,
						fill = "toself",
						fillcolor = "LightSeaGreen",
	                    opacity=0.5,
	                    hoverinfo="none"
					)  
	        push!(vtrace, rectᵢ)
		end
	    rlabels =  PlotlyJS.scatter( 
						x = (1:n) .- 0.5,
						y = fill(0.2,n),
	                    text = labels,
						mode = "text",
						hoverinfo="none"
					)
	    push!(vtrace, rlabels)
	    return vtrace
	end

	"""
	draw_menu(labels,title)
	"""
	draw_menu(labels::Vector{String}, title::String = "") =  
	PlotlyJS.plot( menu_trace(labels), menu_layout(length(labels),title) )