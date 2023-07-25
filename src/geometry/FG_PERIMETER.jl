	gety(v::Vector{Float64},i::Int64,m::Int64)::Float64 = v[i+m]
	getxy(v::Vector{Float64},i::Int64,m::Int64)::Vector{Float64} = v[[i;i+m]]

	"""
	    perim(v)

	Compute the perimeter of a simply-connected polygonal region
	"""
	function perim(v::Vector{Float64})
	
		p = 0.0
		m = length(v) ÷ 2
		for i = 1:m-1
			p += norm(getxy(v,i+1,m)-getxy(v,i,m))
		end
		p += norm(getxy(v,m,m)-getxy(v,1,m))
		return p
	end

	"""
	    ∂perim(v)

	Let x be the two column arragety of contour coordinates.

	Compute the gradient of the contour perimeter  

	with respect to its coordinates
	"""
	function ∂perim(g,v::Vector{Float64})

	    m = length(v) ÷ 2 
	    n₁ = norm(getxy(v,1,m)-getxy(v,m,m))
	    n₂ = norm(getxy(v,1,m)-getxy(v,2,m))
	    nₘ = norm(getxy(v,m,m)-getxy(v,m-1,m))

	    g[1]   = (v[1] - v[2])/n₂ + (v[1] - v[m])/n₁
	    
	    g[m+1] = (gety(v,1,m) - gety(v,2,m))/n₂ + (gety(v,1,m) - gety(v,m,m))/n₁
	    
	    g[m]   = (v[m] - v[m-1])/nₘ + (v[m] - v[1])/n₁
	    
	    g[2m]  = (gety(v,m,m) - gety(v,m-1,m))/nₘ + (gety(v,m,m) - gety(v,1,m))/n₁
	    
	    for i = 2:m-1
	    	xyᵢ = getxy(v,i,m)
	    	xy₋ = getxy(v,i-1,m)
	    	xy₊ = getxy(v,i+1,m)
	    	g[i]  = (v[i]-v[i+1])/norm(xyᵢ-xy₊)
	    	g[i] += (v[i]-v[i-1])/norm(xyᵢ-xy₋)
	    end   
	    
	    for i = m+2:2m-1
	    	xyᵢ = getxy(v,i-m,m)
	    	xy₋ = getxy(v,i-1-m,m)
	    	xy₊ = getxy(v,i+1-m,m)
	    	g[i]  = (gety(v,i-m,m)-gety(v,i+1-m,m))/norm(xyᵢ-xy₊)
	    	g[i] += (gety(v,i-m,m)-gety(v,i-1-m,m))/norm(xyᵢ-xy₋)
	    end
	    return g
	end	

	function fg!(F, G, v)
   		   if G !== nothing
               G[:] = ∂perim(G[:],v)
           end
           if F !== nothing
               return perim(v)
           end
	end