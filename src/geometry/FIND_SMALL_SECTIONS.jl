
	"""
	find_small_sections(R)

	Send a warning if there are small polygonal sections 
	in a subregion of a cut decomposition.
	"""
	function find_small_sections(R::DataRegion,
								 flag::Bool = false
								 )
		ℓtol = 1e-10
		# identify number of the subregion
        iR = R.idreg
        # create a copy of the cuts
		idcuts = copy(R.idcuts)
		# sort cuts to start at lowest index
		idx = sortperm(idcuts[:,1])
		idcuts = idcuts[idx,:]
		# number of cuts
		ncuts = size(idcuts,1)
		# detect at least two cuts
		if ncuts > 1
            ℓmin = Inf
            ℓmax = 0.0
            # loop on cuts
	        for r  = 1:ncuts
	            r₊ = (r==ncuts) ? 1 : r+1
	            # cut indexes
	            p  = idcuts[r,1]
	            p₊ = idcuts[r,end]
	            # length of the cut
                if p ≠ p₊
                    ℓᵣ = arclength(R.E, p, p₊)
                    ℓmin = min(ℓmin,ℓᵣ) 
                    ℓmax = max(ℓmax,ℓᵣ)
                end
                # non-cut indexes
	            p  = idcuts[r,end]
	            p₊ = idcuts[r₊,1]
	            # length of the non-cut polygonal section
	            if p ≠ p₊
	            	ℓᵣ = arclength(R.E, p, p₊)
                    ℓmin = min(ℓmin,ℓᵣ)
                    ℓmax = max(ℓmax,ℓᵣ)           	
	            end
	        end   
	        if ℓmin > ℓtol
            	if log10(ℓmax/ℓmin) > 3.0
                	str = "Warning: small boundary section at region $iR"
                	display(str)
                	flag = true
            	end
        	end
		end
		return flag
	end

	"""
	find_small_sections(Dreg)

	Send a warning if there are small polygonal sections 
	in a cut decomposition.
	"""
	function find_small_sections(Dreg::Dict{Int64,DataRegion})
		flag = false
		for iR in keys(Dreg)
			flag = find_small_sections(Dreg[iR],flag) 
		end
		return flag
	end
