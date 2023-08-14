#=
	"""
	    is_left(): tests if a point is Left|On|Right of an infinite line.

	INPUT
        Three points P0, P1, and P2
	OUTPUT
        >0 for P2 left of the line through P0 and P1
        =0 for P2 on the line
        <0 for P2 right of the line
	"Area of 2D and 3D Triangles and Polygons" 2001
	"""
	function is_left(P₀::Vector{Float64}, 
					P₁::Vector{Float64}, 
					P₂::Vector{Float64}
					)::Float64
	    
	    return 	(P₁[1]-P₀[1])*(P₂[2]-P₀[2]) - 
	    		(P₂[1]-P₀[1])*(P₁[2]-P₀[2])

	end

	"""
	    inpoly(P,q)

	Winding number test for a point q in a polygon P
	wn = the winding number (=0 only if q is outside P)
	INPUT
		P   ->  vertex points of a polygon
		q   ->  1D array with point coordinates
	OUTPUT
		inside (true if wn = 0; false otherwise)
	"""
	function inpoly(P::Matrix{Float64},q::Vector{Float64})::Bool

		# winding number counter
	    wn = 0   
	    # last vertex = first vertex
	    P = P[[1:end;1],:]

	    # loop through all edges of the polygon
	    for i = 1:size(P,1)-1          # edge from P[i] to P[i+1]
	        if P[i,2] <= q[2]        
	            if P[i+1,2] > q[2]     # an upward crossing
	                if is_left(P[i,:], P[i+1,:], q) > 0 # q left of edge
	                    wn += 1        # have a valid up intersect
	                end
	            end
	        else                       # no test needed
	            if P[i+1,2] <= q[2]    # a downward crossing
	                if is_left(P[i,:], P[i+1,:], q) < 0 # q right of edge
	                    wn -= 1        # have a valid down intersect
	                end
	            end
	        end
	    end

	    return (wn ≠ 0) ? true : false
	end

inpoly(E::Matrix{Float64},H::Matrix{Float64})::Vector{Bool} = [inpoly(E,H[i,:]) for i = 1:size(H,1)]
=#