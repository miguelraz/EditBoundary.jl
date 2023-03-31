	"""
	    reflex(Ω)

	Count and get the indexes of the reflex vertices of a simple polygon
	"""
	function reflex(Ω::Matrix{Float64})
		NR 	 = 0
		list = Array{Int64}([])
		# number of boundary points
		nv = size(Ω,1)
		(Ω[1,:]==Ω[end,:]) && (nv-=1)

		# loop to count the number of reflex vertices
		for k = 1:nv
			# index of previous vertex
			k₋ = isone(k) ? nv : k-1 
			# index of next vertex
			k₊ = (k == nv) ? 1 : k+1
			# identify reflex vertices by the signed α of 
			# the triangle given by three consecutive vertices 
			if α(Ω,k₋,k,k₊) < 0 
				push!(list, k)
				NR += 1
			end
		end
		return list, NR		
	end