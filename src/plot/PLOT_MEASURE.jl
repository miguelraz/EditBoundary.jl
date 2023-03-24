
	"""
	plot_measure(μvec)
	"""
	function plot_measure(μvec::Vector{Float64}, name::String = "")
		n = length(μvec)
		trace = PlotlyJS.scatter(
					x = 1:n, 
					y = μvec,
					mode = "markers",
			  		marker_symbol = "circle",
			  		marker_color = "blue",
			  		marker_size = 10
	 			)
		layout = Layout(
					width      = 400,
				    height     = 400,
				    title      = name,
				    xaxis_range= [0,n],
		    		yaxis_scaleanchor = "x",
		    		showlegend = false,
				    hovermode  = false,
				    template   = "plotly_white",
					yaxis_type = "log"
				)
		return PlotlyJS.plot(trace, layout)
	end 

	"""
	plot_measure(Dμ)
	"""
	function plot_measure(
				Dμ::Dict{Int64,Vector{Float64}},
				Dnames::Dict{Int64,String}
				)

		plt = hcat( plot_areas(Dμ[0],Dnames[0]),
					plot_areas(Dμ[1],Dnames[1]),
					plot_areas(Dμ[2],Dnames[2]), 
					plot_areas(Dμ[3],Dnames[3])
					)
		relayout!(plt, 	template = "plotly_white",
						showlegend = false,
						hovermode  = false)
		return plt
	end