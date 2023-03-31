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