
    #=
    Required Modules
    
        RegionStruct
        GET_ANGLES
    =#

    """
	modn(i,n)
	"""
	function modn(i::Int64,n::Int64)::Int64 
	    j = i % n
	    (i ≤ 0) && (j+=n)
	    iszero(j) && (j=n)
	    return j
	end

    """
    find_small_angles(R)
    """
    function find_small_angles(R::DataRegion)
        iR = R.idreg
        for i in R.idcuts
            nE = size(R.E,1)
            θᵢ = get_angle(R.E,modn(i-1,nE),i,modn(i+1,nE))
            if θᵢ ≤ 45.0
                str = "Warning: point $i of region $iR has angle "
                str *= @sprintf "%3.5g" θᵢ
                display(str)
                break
            end
        end
    end