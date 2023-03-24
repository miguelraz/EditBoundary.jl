

	"""
	Ω = depuration(Ω,ltol)
	"""
	function depuration(Ω::Matrix{Float64},
						ltol::Float64 = 1e-10,
						)::Matrix{Float64}

		αΩ = 0.0
		pΩ = 0.0
		nΩ = size(Ω,1)
		lvec = zeros(nΩ)
		# loop on vertices
        for k = 1:nΩ
        	k₋ = isone(k)  ? nΩ : k-1 
            k₊ = (k == nΩ) ? 1  : k+1        
            dx = Ω[k₊,1] - Ω[k,1]
            dy = Ω[k₊,2] - Ω[k,2]
            # length of segment
            lvec[k] = √(dx*dx+dy*dy)
            # update area of region
            αΩ += Ω[k,:]'*J₂(Ω[k₊,:])
            # update perimeter of region
            pΩ += lvec[k]
        end
        # scaling
        αΩ *= 0.5 
        lvec ./= pΩ
		# find repeated points
    	idrep = findall(x->x≤ltol,lvec)
    	if ~isempty(idrep)
    		nrep = length(idrep)
    	end
    	# indexes of non-repeated points
    	idx = setdiff(1:nΩ,idrep)
    	# update number of points
    	nΩ = length(idx)
    	# delete repeated points
    	Ω = Ω[idx,:] 
		# change orientation
		if  αΩ < 0
			idrange = [1;nΩ:-1:2]
			Ω = Ω[idrange,:]
		end
		return Ω
	end

	"""
	R = depuration(R,ltol)
	"""
	function depuration(R::DataRegion,
						ltol::Float64 = 1e-10,
						)::DataRegion

		R.E = depuration(R.E,ltol)
		if ~isempty(R.H)
			for k in keys(R.H)
				R.H[k] = depuration(R.H[k],ltol)
			end
		end
		return R
	end
