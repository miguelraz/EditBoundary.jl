
	#######################################################################
	#		 ROUTINES TO GET THE POCKETS OF A POLYGONAL REGION    		  #
	#######################################################################

	#=
	Required modules
			AREA,
			SCALEINB2,
			HULL
	=#


	#######################################################################
	#		 ROUTINES TO GET THE POCKETS OF A POLYGONAL REGION    		  #
	#######################################################################

	#=
	Required modules
			AREA,
			SCALEINB2,
			HULL
	=#

	"""
	idpockets(p,q,nv,nc,k)

	Rutina que identifica los vértices del bolsillo que inicia en vp

	y termina en vq	

	ENTRADA: 
	
			p   -> índice del vértice donde inicia el bolsillo
	
			q   -> índice del vértice donde termina el bolsillo
	
			nc  -> número de vértices del contorno
	
			ne  -> número de vértices en la envolvente convexa
	
			k   -> índice del vértice en la envolvente convexa
	
	SALIDA:
	
			Iv  -> arreglo con los índices de los vértices en la envolvente convexa
	"""
	function idpockets(	p::Int64, q::Int64, nc::Int64,
						ne::Int64, k::Int64)::Vector{Int64}

		Iv = Int64[]
		if k == ne
			if p < nc && q > 1 
				Iv = [ p+1:nc; 1:q-1 ]
			elseif p == nc && q > 1
				Iv = 1 : q-1
			elseif p < nc & q == 1
				Iv = p+1 : nc
			end
		else
			q > p+1 && ( Iv = p+1 : q-1 )
	 	end

	 	return collect(Iv)
	end


	"""
	pockets(Ω,ide)

	Routine to get the pockets of a simply-connected polygonal region and their areas.

	INPUT

		Ω 	->	two column array of coordinates of boundary points of the region

	  	ide -> index array of the boundary points of the convex hull 

	OUTPUT

		DictPocket  -> dictionary of largest pockets of the region

		DictAreas   -> dictionary of the pocket areas

		tolA		-> threhold for pocket areas 
	"""
	function pockets(Ω::Array{Float64}, ide::Array{Int64})

		# initialize number of pockets
		npockets  = 0
		# initialize concavity measures
		concavity₁ = 0.0
		concavity₂ = 0.0
		# number of boundary points in the region
		nv = size(Ω,1)
		Ω[1,:] == Ω[end,:] && (nv-=1)
		# number of boundary points in the convex hull
		ne = length(ide)
		# scale the region
		fesc = scaleinB₂(Ω)
		Ω *= fesc
		# array of indexes of pairs of boundary points in the hull 
		CH_idx = [ide[1:end-1] ide[2:end]; ide[end] ide[1] ]
		# loop on the hull boundary points
		for k = 1:ne
			# indexes of a pair of consecutive points in the hull
			q = CH_idx[k,1]
			p = CH_idx[k,2]
			# indexes of points between a pair of consecutive points in the hull
			Ib = idpockets(p,q,nv,ne,k)
			# identify pockets
		 	if  ~isempty(Ib)
		 		# pocket indexes
		 		pidx = [p;q;reverse(Ib);p]
		 		# pocket points
		 		P = Ω[pidx,:]
		 		# pocket area
		 		A = abs(α(P))
		 		if A ≠ 0
			 		# update counter
			 		npockets += 1
					# update largest pocket distances 
					dᵢ = 0 
					# inicializa índices de vértices con medida de concavidad 
					# más grande
					id = 0
					# loop to compute concavity measures of the pocket points
					for i ∈ Ib
			      		# straight line distance to the bridge vpvq 
			      		CSᵢ = distseg(Ω, i, p, q)
			      		# arclenth distance to the bridge vpvq
			      		CAᵢ = arclength(Ω, i, p, q)
			      		# replace concavity measures with largest ones
			      		concavity₁ < CSᵢ && ( concavity₁ = CSᵢ )
			      		concavity₂ < CAᵢ && ( concavity₂ = CAᵢ )
	      		    end
		 	 	end
		 	end
		end
		concavity₂ /= perimeter(Ω)
		return npockets, concavity₁, concavity₂
	end	

	"""
	pockets(Ω)

	Routine to get the pockets of a simply-connected polygonal region

	INPUT

		Ω -	two column array of coordinates of boundary points of the region

			the first point ≠ the last point

	OUTPUT

		CH - two column array of coordinates of boundary points of the convex hull

		DictPocket - dictionary of largest pockets of the region
	"""
	function pockets(Ω::Array{Float64})
		Ωhull, ide = convex_hull(Ω)
		αhull = abs(α(Ωhull))
		phull = perimeter(Ωhull)
		npockets, concavity₁, concavity₂ = pockets(Ω,ide)
		return npockets, concavity₁, concavity₂, αhull, phull
	end
