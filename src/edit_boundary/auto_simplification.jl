#=
"""
    auto_simplification(Ω,tolsmt,tolcol,tolrad)

Automatic mode for polygon simplification.
Subroutine for simply connected polygons
"""
function auto_simp(Ω₀::Matrix{Float64},
    tolsmt::Float64,
    tolarea::Float64
)

    Ω = copy(Ω₀)
    # check if the polygon is a digital contour
    checkint = sum(isinteger.(Ω)) == prod(size(Ω))
    # iterative point elimination by ϵ-test
    Ω = del_pts(areasine, Ω, 0.1)
    # smooth polygonal curve by minimizing its perimeter
    Ω .= min_perimeter(Ω, tolsmt)
    # iterative point elimination by ϵ-test
    # use 0.1 without noise and 0.4 with noise
    Ω = del_pts(areasine, Ω, tolarea)
    # rounding
    checkint && (Ω .= round.(Ω))
    return Ω
end

"""
    auto_simp!(R₀,R,tolsmt,tolarea)

Automatic mode for polygon simplification.
Subroutine for polygonal regions.

	1. Delete points by ϵ-test
	2. Polygon smoothing 
	3. Delete points by ϵ-test
	4. Rounding for digital curves
	
INPUT:
    - R₀  	  data structure of the original region
    - R  	  data structure of the approximate region
    - tolsmt  smoothing level 
    - tolauto tolerance for automatic mode
OUTPUT
    - `nothing`, (R is overwritten)
"""
function auto_simp!(R₀::DataRegion,
    R::DataRegion,
    tolsmt::Float64,
    tolarea::Float64
)
    R.E = auto_simp(R₀.E, tolsmt, tolarea)
    if ~isempty(R.H)
        for k in keys(R₀.H)
            R.H[k] = auto_simp(R₀.H[k], tolsmt, tolarea)
        end
    end
end
=#