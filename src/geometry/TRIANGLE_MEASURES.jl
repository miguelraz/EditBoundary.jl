
	"""
	    get_cos(P,Q,R)

	Compute cos(Q) in the triangle PQR using the dot product
	"""
	function get_cos(P::Vector{Float64},
					 Q::Vector{Float64},
					 R::Vector{Float64})

		# vectors with starting point in Q
	    v = P-Q
	    u = R-Q
	    # normalization
	    v ≠ 0 && (v /= √(v'v))
	    u ≠ 0 && (u /= √(u'u))
	    # dot product 
	    uᵀv  = u'v
	    # dot product in the interval [-1,1]
	    if uᵀv < -1
	    	uᵀv = -1
	    elseif uᵀv > 1
	    	uᵀv = 1
	    end
	    return uᵀv
	end

	"""
	    areas(P,Q,R)

	Area of triangle PQR
	"""
	areas(P::Vector{Float64}, Q::Vector{Float64}, R::Vector{Float64}) = 0.5abs(α(P,Q,R))

	"""
	    areasine(P,Q,R)

	Area of triangle PQR weighted by the sine of the interior angle
	"""
	function areasine(P::Vector{Float64},Q::Vector{Float64},R::Vector{Float64})
	    # Compute cos(Q) using the dot product
	    s  = get_cos(P,Q,R)
        # sin(Q) =√1-cos(Q)²
        s  = √(1.0-s*s)
        # Compute area of the triangle PQR and multiply it
        s *= areas(P,Q,R)
        return s
	end

	"""
	    radiusine(A,B,C)

	Get double product inradius r × circunradius R weighted
	by the sine of the interior angle
	"""
	function radiusine(A::Vector{Float64},B::Vector{Float64},C::Vector{Float64})
        a = norm(B-C)
        b = norm(A-C)
        c = norm(A-B)
        # Compute cos(B) using Cosine rule: b²=a²+c²-2ac⋅cos(B)
	    s = a*a+c*c-b*b
	    s/= 2a*c
	    # sin(B) =√1-cos(B)²
	    s = 1.0-s*s
        s = s ≥ 0 ? √s : 0.0
        # 2rR = a⋅b⋅c/(a+b+c)
        s*= a*b*c/(a+b+c)
        return s 
	end

carnot(P::Vector{Float64},Q::Vector{Float64},R::Vector{Float64}) = get_cos(P,Q,R) + get_cos(Q,R,P) + get_cos(R,P,Q) - 1