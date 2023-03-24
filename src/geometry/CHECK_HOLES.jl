
    """
    check_holes(R)
    """
    function check_holes(R::DataRegion, flag::Bool=false)::Bool

        iR = R.idreg
        label = iszero(iR) ? R.name : string(iR)
        nH = length(R.H)
        if nH ≠ 0  
            display("region "*label*" has $nH holes")
            flag = true
        end
        return flag
    end

    """
    flag = check_holes(Dreg)
    """
    function check_holes(Dreg::Dict{Int64,DataRegion})::Bool
        flag = false
        for iR in keys(Dreg)
            flag = check_holes(Dreg[iR],flag)
        end
        return flag
    end 
