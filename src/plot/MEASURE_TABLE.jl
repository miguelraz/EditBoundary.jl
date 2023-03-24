

	"""
	qtable = measure_table(tabvalues)
	"""
	function measure_table( tabvalues::Matrix{String},
							measure::String
						  )

		trace = table(
			 rowwidth = fill(300,size(tabvalues,1)),
		     header=attr(
		            values=["Region", "Mesh Size", measure],
		            align=["left", "left", "left"], 
		            line=attr(width=1, color="#506784"),
		            fill_color="#119DFF",
		            font=attr(family="Arial", size=20, color="white")
		            ),
		     cells=attr(
		            values=tabvalues, 
		            align=["left", "left", "left"],
		            line=attr(color="#506784", width=1),
		            font=attr(family="Arial", size=20, color="blue"),
		            fill_color=["white","white","#25FEFD"]
		            )
		     )
		layout = Layout(width=600)
		return PlotlyJS.plot(trace,layout)
	end