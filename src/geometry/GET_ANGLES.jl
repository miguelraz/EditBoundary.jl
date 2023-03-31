
	"""
	    get_cos(P,Q,R)

	compute cosine of the angle using the dot product
	"""
	function get_cos(P::Vector{Float64},
					 Q::Vector{Float64},
					 R::Vector{Float64})

		# vectors with starting point in Q
	    v = P-Q
	    u = R-Q
	    # normalization
	    v ≠ 0 && (v /= √(v'v))
	    u ≠ 0 && (u /= √(u'u))
	    # dot product 
	    uᵀv  = u'v
	    # dot product in the interval [-1,1]
	    if uᵀv < -1
	    	uᵀv = -1
	    elseif uᵀv > 1
	    	uᵀv = 1
	    end
	    return uᵀv
	end

	function get_angle(	P::Vector{Float64},
						Q::Vector{Float64},
						R::Vector{Float64})

	    # angle in degrees = arc cosine of the dot product
	    θ = acos(get_cos(P,Q,R))
	    # angle convertion from radians to degrees
	    return  rad2deg(θ)
	end

    """
	get_angle(Ω,k₋,k,k₊)
	"""
	function get_angle(	Ω::Matrix{Float64}, 
						k₋::Int64, 
						k::Int64, 
						k₊::Int64
						)
		
		θ = get_angle(Ω[k₋,:],Ω[k,:],Ω[k₊,:])
		if α(Ω,k₋,k,k₊) < 0
			θ = 360.0 - θ
		end
		return θ
	end

	function get_angle(Ω::Matrix{Float64})
	    
	    nΩ = size(Ω,1)
	    θvec = zeros(nΩ)
	    θvec[1] = get_angle(Ω,nΩ,1,2)
	    for k = 2:nΩ-1	    
	    	θvec[k] = get_angle(Ω,k-1,k,k+1)	    
	    end
	    θvec[end] = get_angle(Ω,nΩ-1,nΩ,1)

	    return θvec
	end