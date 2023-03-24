
	"""
	Rcopy = copy_region(R)
	"""
	function copy_region(R::DataRegion)::DataRegion
	    
	    H = Dict{Int64,Matrix{Float64}}()
	    if ~isempty(R.H)
	    	for k in keys(R.H)
	        		H[k] = copy(R.H[k])
	    	end
	    end

	    Rcopy = DataRegion( copy(R.E), 
						  	H,
		                  	copy(R.idcuts), 
		                  	R.idreg,
		                  	R.name 
		                  	)
	    return Rcopy
	end