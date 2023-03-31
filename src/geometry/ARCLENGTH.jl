
	function lengths(Ω::Matrix{Float64})::Vector{Float64}
		dx = Ω[[2:end;1],1] - Ω[1:end,1]
	    dy = Ω[[2:end;1],2] - Ω[1:end,2]
	    return .√(dx.^2+dy.^2)
	end

	"""
	    arclength(C)

    Compute the arclength of a polygonal curve C
	"""
	function arclength(C::Matrix{Float64})::Float64 

		ℓ = 0
		m = size(C,1)
		for i = 1:m-1
			ℓ += norm(C[i+1,:]-C[i,:])
		end
		return ℓ
	end

	"""
	    perimeter(Ω)

    Compute the perimeter of a simply-connected polygonal region
	"""
	perimeter(Ω::Matrix{Float64})::Float64 = arclength(Ω) + norm(Ω[end,:]-Ω[1,:])
	

	"""
	    arclength(C, i, j)

	Let v₁,…,vₙ be the points of the polygonal curve C

	Compute the arc length ℓ of path vᵢvⱼ

	i<j ⇒ ℓ = Σₖ₌ᵢʲ⁻¹ ||vₖ₊₁ -vₖ||₂²  
	"""
	function arclength(C::Matrix{Float64}, i::Int64, j::Int64)::Float64
	    
	    if i == j
	        ℓ = 0.0
	    elseif i < j
	        ℓ = sum( .√( sum( (C[i+1:j,:]-C[i:j-1,:]).^2; dims = 2) ) )
	    else
	        ℓ  = sum( .√( sum( (C[i+1:end,:]-C[i:end-1,:]).^2; dims = 2) ) )
	        ℓ += sum( .√( sum( (C[2:j,:]-C[1:j-1,:]).^2; dims = 2) ) )
	        ℓ += √sum( (C[end,:]-C[1,:]).^2)
	    end
	    return ℓ
	end

  	"""
  	    arclength(C, i, p, q)

  	Let v₁,…,vₙ be the points of the polygonal curve C

  	Compute the length of the smallest of the paths vₚvᵢ and vᵢvq
  	"""
  	function arclength(C::Array{Float64},i::Int64,p::Int64,q::Int64)::Float64

    	n = size(C,1)
    	# compute the arclength of path vivq	
    	ℓiq = (i ≤ q) ? arclength(C,i,q) : ( arclength(C,i,n) + norm(C[1,:]-C[n,:]) + arclength(C,1,q) )
    	# compute the arclength of path v_pv_i
    	ℓpi = (p ≤ i) ? arclength(C,p,i) : ( arclength(C,p,n) + norm(C[1,:]-C[n,:]) + arclength(C,1,i) )
    	# return the smallest length
    	return min(ℓpi,ℓiq)
  	end

	function arclength(Ω::Matrix{Float64},id::Array{Int64})

		id = id[[1:end;1]]

	    return [arclength(Ω,id[k],id[k+1]) for k=1:4]
	end