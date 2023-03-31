	function triangle_radius(Ω::Matrix{Float64})::Vector{Float64}

		# number of points in the exterior boundary
		nΩ = size(Ω,1)
		# initialize index array
		rvec = zeros(nΩ)	
		# loop on points
        for k = 1:nΩ
            # previous index
            k₋ = isone(k)  ? nΩ : k-1
            # next index
            k₊ = (k == nΩ) ? 1  : k+1
            # cosine of the angles of the triangle 
            c₁ = get_cos(Ω[k₋,:],Ω[k,:],Ω[k₊,:])
            c₂ = get_cos(Ω[k,:],Ω[k₊,:],Ω[k₋,:])
            c₃ = get_cos(Ω[k₊,:],Ω[k₋,:],Ω[k,:])
	    	# compute radius incircle / radius excircle
            # by Carnot's theorem 
            rvec[k] =  c₁ + c₂ + c₃ - 1.0
        end
		return rvec
	end

    function triangle_radius(R::DataRegion)::Vector{Float64}
        rvec = triangle_radius(R.E)
        if ~isempty(R.H)
            for k in keys(R.H)
                rvec = vcat(rvec,triangle_radius(R.H[k]))
            end
        end
        return rvec
    end

    function triangle_radius_sorted(R::DataRegion)::Vector{Float64}
        rvec = triangle_radius(R)
        sort!(rvec,rev=true)
        return rvec
    end