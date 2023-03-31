
	"""
	    distseg(a,b,p)

	Compute euclidean distance from the segment ab 
	to the point p.
	"""
	function distseg(a::Union{Vector{Float32},Vector{Float64}}, 
					 b::Union{Vector{Float32},Vector{Float64}}, 
					 p::Union{Vector{Float32},Vector{Float64}}
					 )

		 	u = b-a
	        v = p-a
			c = (u'v)/(u'u)
			if  c > 1
		    	proy = b
			else
				proy = a
		       	(0 ≤c ≤ 1) && (proy += c*u)
		    end
		    return norm(p-proy)
	end
distseg(C::Matrix{Float64}, i::Int64, p::Int64, q::Int64) = distseg(C[p,:],C[q,:],C[i,:])