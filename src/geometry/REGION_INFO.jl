	function basic_region_info(Ω::Matrix{Float64})

		nΩ = size(Ω,1)
		# initialize measures
		tolcol  = 1e-4
		ᾱ  = 0.0
		αΩ = 0.0
		pΩ = 0.0
		nreflex = 0
		nsmallθ = 0
		αvec = zeros(nΩ)
		measure_vec = zeros(nΩ)
		# loop on points
        for k = 1:nΩ
        	 # previous index
        	k₋ = isone(k)  ? nΩ : k-1 
        	 # next index
            k₊ = (k == nΩ) ? 1  : k+1 
            # length of the segment
            dx = Ω[k₊,1] - Ω[k,1]
            dy = Ω[k₊,2] - Ω[k,2]
            ℓₖ = √(dx*dx+dy*dy)
            # update perimeter of region
            pΩ += ℓₖ
            # signed area of triangle
            αvec[k] = α(Ω,k₋,k,k₊)
            # update average area of triangles
            ᾱ  += abs(αvec[k])
            # update region area
            αΩ += Ω[k,:]'*J₂(Ω[k₊,:])
            # interior angle
            θₖ = get_angle(Ω[k₋,:],Ω[k,:],Ω[k₊,:])
            # detect reflex points
            αvec[k] < 0 && (nreflex += 1; θₖ = 360.0 - θₖ)
            # detect small angles
			θₖ ≤ 45.0 && (nsmallθ += 1)
			# sine of the interior angle in radians 
			sₖ = sin(deg2rad(θₖ))
			# triangle area × sine of the angle 
			measure_vec[k] = αvec[k]*sₖ
        end
        # region area
        αΩ = 0.5abs(αΩ)
        # scaling
        ᾱ /= nΩ 
        measure_vec ./= ᾱ
        measure_vec ./= tolcol
        # detect bad points
        idbad = findall(x->x < 1.0, measure_vec)
        # number of removable points
        nrem = length(idbad)
		return nΩ, nreflex, nsmallθ, nrem, pΩ, αΩ
	end

	function basic_region_info(R::DataRegion)
		# labels for region table
		labels = [  "Region", "Holes", "Ext Pts", "Hole Pts",
           	 		"Removable Pts", "Small Angles", "% Reflex", "Area"]
		# info of the holes
		nH = length(R.H)
		nHpts = iszero(nH) ? 0 : sum(size(R.H[k],1) for k =1:nH)
		# boundary info
		nEpts, nreflex, nsmallθ, nrem, pΩ, αΩ = basic_region_info(R.E)
		nreflex = Int64(round(100nreflex/nEpts)) 
		nHpts = 0
		if nH > 0
			for k in keys(R.H)
				nHptsₖ, nremₖ, αₖ = basic_region_info(R.H[k])[[1,4,6]] 
				nHpts += nHptsₖ
				nrem  += nremₖ
				αΩ    -= αₖ
			end
		end
		# collect info
		name = R.name*" "
		R.idreg ≠ 0 && ( name *= string(R.idreg) )
		ndata   = [nH, nEpts, nHpts, nrem, nsmallθ, nreflex]
		infovec = [name; string.(ndata); @sprintf " %1.3e" αΩ]
		return labels, infovec
	end