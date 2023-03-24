
	"""
	region_table(labels,tabvalues)
	"""
	function region_table(labels::Vector{String}, 
        			     tabvalues::Array{String}
        			     )

		ncol = size(tabvalues,2)
		tab_width = isone(ncol) ? 400 : 700
		trace = table( 
				 cells = attr(
				            values = [labels tabvalues], 
				            align = fill("left",ncol),
				            line = attr(color = "#506784", 
				            			width = 1
				            			),
				            font = attr(family = "Arial", 
				            			size = 14, 
				            			color = "blue"
				            			),
				            fill_color = ["#25FEFD","white"]
				            )
					)
		layout = Layout(width = tab_width, height = 500)
		return PlotlyJS.plot(trace,layout)
	end

    """
    region_table(tabvalues)
    """
    function region_table(tabvalues::Array{String})

        labels = [  "Region", "Holes", "Ext Bnd Pts",
                    "Reflex Pts", "Non-Admissible Pts", 
                    "Small Angles", "Pockets", 
                    "Perimeter", "Area", 
                    "ℓₘᵢₙ", "ℓₘₐₓ", "αₘᵢₙ", "αₘₐₓ" 
                 ]
        return region_table(labels,tabvalues)
    end
