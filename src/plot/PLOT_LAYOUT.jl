
	Daxis = Dict{Any,Any}( 
	    :showgrid       => false,
	    :showticklabels => false,
	    :zeroline       => false,
	    )
	DicLay = Dict(
	    :autosize   => false,
	    :width      => 1000,
	    :height     => 1000,
	    :showaxis   => false,
	    :showlegend => false,
	    :title      => "",
	    :hovermode  => false,
	    :xaxis      => Daxis,
	    :yaxis      => Daxis,
	    :template 	=> "plotly_white"
	    )
	DicLay[:yaxis][:scaleanchor] = "x"	

	layoutB = Layout(DicLay)
	layoutC = Layout(DicLay)
	layoutR = Layout(DicLay)
	layoutC[:hovermode]  = "closest"
	layoutR[:hovermode]  = "closest"
	layoutR[:showlegend] = true

	"""
	menu_layout(n,mtitle)
	"""
	function menu_layout(n::Int64,mtitle::String="")

		mlayout = Layout(
		    template = "plotly_white",
		    showlegend = false,
		    xaxis_range=[0,n],
		    yaxis_range=[0,0.5],
		    yaxis_scaleanchor = "x",
		    xaxis_showgrid       = false,
			xaxis_showticklabels = false,
			xaxis_zeroline       = false,
		    yaxis_showgrid       = false,
			yaxis_showticklabels = false,
			yaxis_zeroline       = false,
		    autosize = false,
		    width  = 250n,
			height = 200,
		    title = mtitle,
		  )
	    return mlayout
	end

	"""
	showviz(nR, show_blocks, 
			show_corners, 
			show_cells, 
			flag_low, show_low,
			flag_bad, show_bad,
			flag_nc, show_nc)
	"""
	function showviz(nR::Int64,  
				show_blocks::Bool,
				show_corners::Bool,
				show_cells::Bool,
				flag_low::Bool,
				show_low::Bool,
				flag_bad::Bool,
				show_bad::Bool,
				flag_nc::Bool,
				show_nc::Bool
			)

		vecvis = [ fill(show_blocks,nR); show_corners; show_cells]
		flag_low && push!(vecvis, show_low)
		flag_bad && push!(vecvis, show_bad)
		flag_nc  && push!(vecvis, show_nc)
		return vecvis
	end

	"""
	bmesh_layout(nR, flag_low, flag_bad, flag_nc)
	"""
	function bmesh_layout(
				nR::Int64, 
				flag_low::Bool, 
				flag_bad::Bool, 
				flag_nc::Bool
			)

		layoutM  = Layout(DicLay)
		layoutM[:hovermode]   = "closest"
		layoutM[:updatemenus] = [
			        attr(
			            buttons=[
			            	attr(
			                    args   = [attr(visible =
				                    		showviz(nR, 
				                    			true, true, false, 
												flag_low, false,
												flag_bad, false,
												flag_nc, false
											)
			                    		)],
			                    label  = "Decomposition",
			                    method = "update"
			                ),
			                attr(
			                    args   = [attr(visible = 
				                    		showviz(nR, 
				                    			true, false, true, 
												flag_low, false,
												flag_bad, false,
												flag_nc, false
											)
			                    		)],
			                    label  = "Block Mesh",
			                    method = "update"
			                ),
			                attr(
			                    args   = [attr(visible = 
				                    		showviz(nR, 
				                    			false, false, true, 
												flag_low, true,
												flag_bad, true,
												flag_nc, false
											)
			                    		)],
			                    label  = "Quality map",
			                    method = "update"
			                ),
			                attr(
			                    args   = [attr(visible = 
				                    		showviz(nR, 
				                    			false, false, true, 
												flag_low, false,
												flag_bad, false,
												flag_nc, true
											)
			                    		)],
			                    label  = "Convexity map",
			                    method = "update"
			                )
			            ],
			            direction="right",
			            xanchor="left",			         
			            yanchor="bottom",
			            showactive=true,
			            pad_r=10,
			            pad_t=10,
			            x=0.1,
			            y=0.0
			        )
			    ]
		return layoutM
	end

	"""
	region_colors_RGB(nR)
	"""
	region_colors_RGB(nR::Int64) =
	distinguishable_colors(nR,[RGB(1,1,1), RGB(0,0,0)], dropseed=true)

	"""
	region_colors(nR)
	"""
	region_colors(nR::Int64) = hex.(region_colors_RGB(nR))
