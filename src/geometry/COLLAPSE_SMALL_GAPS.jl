
	"""
	collapse_small_gaps(Ω,idcuts)
	"""
	function collapse_small_gaps(Ω::Matrix{Float64}, idcuts::Matrix{Int64})

        # tolerance for repeated points
        ℓtol = 1e-10
		# sort cuts to start at lowest index
		idx = sortperm(idcuts[:,1])
		idcuts = idcuts[idx,:]
        # number of points
        nΩ = size(Ω,1)
		# number of cuts
		ncuts = size(idcuts,1)
		# detect at least two cuts
		if ncuts > 1
            ℓmax = 0.0
            delist = Vector{Int64}()
            # initialize dictionary of polygonal sections:
            # indexes of the ending points and length
            # odd keys are cuts
            # even keys are non cuts
            DpsecID = Dict{Int64,Tuple{Int64, Int64, Float64}}()
            DpsecPT = Dict{Int64,Matrix{Float64}}()
            # loop on cuts to fill dictionary
	        for r  = 1:ncuts
	            r₊ = (r==ncuts) ? 1 : r+1
	            # cut indexes
	            i  = idcuts[r,1]
	            i₊ = idcuts[r,end]
	            # cut length
                ℓᵣ = arclength(Ω, i, i₊)
                # update largest length
                ℓmax = max(ℓmax,ℓᵣ)
                # update dictionary
                DpsecID[2r-1] = (i,i₊,ℓᵣ)
                DpsecPT[2r-1] = Ω[bndpath(i,i₊,nΩ),:]
                # non-cut indexes
	            i  = idcuts[r,end]
	            i₊ = idcuts[r₊,1]
	            # length of the non-cut polygonal section
	            ℓᵣ = arclength(Ω, i, i₊)
                # update largest length
                ℓmax = max(ℓmax,ℓᵣ)    
                # update dictionary
                DpsecID[2r] = (i,i₊,ℓᵣ)
                DpsecPT[2r] = Ω[bndpath(i,i₊,nΩ),:]
	        end
            # loop on cuts to detect small polygonal sections
            for r  = 1:ncuts
                DpsecID[2r-1][3] < ℓtol && push!(delist,2r-1)
                if  DpsecID[2r][3] < ℓtol
                    push!(delist,2r)
                else 
                    log10(ℓmax/DpsecID[2r][3]) > 3.0 && push!(delist,2r)
                end  
            end
            if ~isempty(delist)
                # create a new boundary with the small polygonal sections removed
                Ω = Matrix{Float64}(undef,0,2)
                for r = 1:ncuts
                    if 2r-1 ∉ delist 
                        pts = DpsecPT[2r-1]
                        2r-2 ∈ delist && ( pts = pts[2:end,:] ) 
                        Ω = vcat(Ω,pts)
                    end
                    2r ∉ delist && ( Ω = vcat(Ω,DpsecPT[2r])   ) 
                end
                (2ncuts ∈ delist) && ( Ω = Ω[2:end,:] )
                Ω = unique(Ω;dims=1)
                # update number of points
                nΩ = size(Ω,1)
                # reinitialize indexes of cuts
                idcuts = Matrix{Int64}(undef,0,2)
                # loop on the cuts to retrieve new cut indexes
                for r = 1:ncuts
                    cut = DpsecPT[2r-1][[1,end],:]
                    if  cut[1,:] ≠ cut[2,:]
                        for i  = 1:nΩ
                            i₊ = (i==nΩ) ? 1 : i+1
                            seg = Ω[[i,i₊],:]
                            if  cut ≈ seg || cut ≈ reverse(seg;dims=1)
                                idcuts = [idcuts;i i₊]
                            end
                        end
                    end
                end
            end
        end
        return Ω, idcuts
	end

	"""
	collapse_small_gaps(R)
	"""
	function collapse_small_gaps!(R::DataRegion)
        display(size(R.E,1))
	    E , idcuts = collapse_small_gaps(R.E, R.idcuts)
        display(size(E,1))
        R.E = E 
        R.idcuts = idcuts
	end