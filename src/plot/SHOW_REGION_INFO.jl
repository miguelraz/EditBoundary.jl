
	"""
	show_region_info(R)
	"""
	function show_region_info(R::DataRegion)
		# get region measures
		labels, infovec = basic_region_info(R)
	   	# draw region
		display(plot_region(R))
		# show tables of region measures
		display(region_table(labels,infovec))
		# check for self-intersections
		folding(R)
	end
	