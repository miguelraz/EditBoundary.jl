
	"""
	plot_simp_per(tol_range,simp_per)
	"""
	function plot_simp_per(tol_range::Vector{Float64}, simp_per::Vector{Float64})
	    
	    tolmax = last(tol_range) 
	    trace = PlotlyJS.scatter(
					x = tol_range, 
	                y = simp_per,
					mode = "markers+lines",
	                marker_symbol = "circle",
	                marker_color = "blue",
	                marker_size = 5,
	                line_color = "blue",
					line_width = 2,
					hoverinfo = "none"
	        )
	    layout = Layout(
						width      = 400,
					    height     = 400,
	                    xaxis_title = "tolerance",
	                    yaxis_title = "percentage of deleted points",
					    xaxis_range= -2:3,
			    		yaxis_scaleanchor = "x",
			    		showlegend = false,
					    hovermode  = false,
					    template   = "plotly_white",
						xaxis_type = "log"
					)
	    return PlotlyJS.plot(trace, layout)
	end