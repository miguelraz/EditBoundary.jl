
    """
    tol2per(R₀,tol_range)

    Get simplification percentages at the given simplification tolerances

    INPUT

    - R₀          contour 
    - tol_range   tolerance range
    """
    function tol2per(R₀::DataRegion, tol_range::Vector{Float64})::Vector{Float64}
         # array to store the percentage of remaining points
         simp_per = similar(tol_range)
         # number of points before simplification
         n₀ = get_npts(R₀)
         # create a copy of the original region in order to modify it 
         R = copy_region(R₀)
         # loop on tolerance range
         for i in eachindex(tol_range)
                tol = tol_range[i]
                # polygon simplification by radius test  
                del_pts!(radiusine, R₀, R, tol)
                # number of points of simplfied region
                n = get_npts(R)
                # percentage of remaining points with respect to the original region
                simp_per[i] = round(100(1-n/n₀),digits=1)
         end
         return simp_per
    end

    """
    get_tolerances_slider_values(R)
    """
    function get_tolerances_slider_values(R::DataRegion)
        # tolerance range
        tol_range = [100:-10:10; 8:-2:2; 0.8:-0.2:0.2; 0.08:-0.02:0.02]
        # simplification percentages
        simp_per  = tol2per(R,tol_range)
        # omit repeated values
        idx = unique(i -> simp_per[i], 1:length(simp_per))
        slider_range  = simp_per[idx]
        tol_range     = tol_range[idx]
        return slider_range, tol_range
    end