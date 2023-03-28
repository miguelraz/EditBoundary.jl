	function get_region()
		# read region file
		R = read_region()
		# change orientation and delete repeated points
		R = depuration(R)
		# save region 
		save_new_region(R)
		return R
	end
