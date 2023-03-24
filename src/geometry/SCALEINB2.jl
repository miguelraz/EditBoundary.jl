
	"""
	scaleinB₂(Ω)
	"""
	function scaleinB₂(Ω::Matrix{Float64})::Float64

		# number of points
		nv = size(Ω,1)
		(Ω[1,:]==Ω[end,:]) && (nv-=1) 
		# mass center
		c  = sum(Ω[1:nv,:]; dims=1)'/nv
		# distance from mass center to the farest point
		r  = maximum([ norm(Ω[k,:]-c) for k =1:nv ])
		# scale factor = inverse of ratio
		return 1/r
	end
