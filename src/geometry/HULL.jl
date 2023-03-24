

	#######################################################################
	# 		Módulo para calcular la envolvente convexa de un contorno 	  #
	#######################################################################

	#
	#######################################################################
	#	 							RUTINAS 							  #
	#######################################################################
	#
	getx(v::Vector{Float64}) = first(v)
	gety(v::Vector{Float64}) = last(v)
	getx(M::Matrix{Float64}) = M[:,1]
	gety(M::Matrix{Float64}) = M[:,2]

	function orientation(p::Vector{Float64}, 
						 q::Vector{Float64}, 
						 r::Vector{Float64}
						 )::Int64
		val = 	( gety(q) - gety(p) ) * ( getx(r) - getx(q) ) - 
				( getx(q) - getx(p) ) * ( gety(r) - gety(q) ) 
	    return (val ≈ 0) ? 0 : ( (val > 0) ? 1 : 2 )
	end



	"""
	convex_hull(C)

	Rutina que calcula los vértices de la envolvente convexa 

	del contorno polígonal y sus índices

	ENTRADA: 

			C   ->  Arreglo Float64 de 2 columnas con las coordenadas

					de los puntos del contorno
	SALIDA:

			CH  ->  Arreglo Float64 de 2 columnas con las coordenadas

					de los puntos de la envolvente convexa

			ide ->  Arreglo con índices de los vértices en la envolvente convexa

	REQUIERE:

			QHull -> Módulo para calcular envolvente convexa

	"""
	function convex_hull(C::Matrix{Float64})

	    n = size(C, 1) 
		@assert (n > 2) "Convex Hull requires at least 3 points." 
	    idx  = Array{Int64}([])
	    p, q = argmin( getx(C) ), 0
	    init = p
		while ( p != init ) || ( length( idx ) == 0 )
			push!( idx, p ) 
			q = (( p + 1) % n ) + 1
			for i in 1:n 
	            if orientation(C[p,:],C[i,:],C[q,:]) == 2 
	                q = i 
	            end
	        end
	        p = q
	    end
	    idx = sort!(idx, rev = true)
	    push!(idx,first(idx))
	    CH = C[idx,:]
	    pop!(idx)
	    return CH, idx
	end
