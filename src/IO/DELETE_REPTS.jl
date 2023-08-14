#=
#=
Required subroutines

	RegionStruct: DataRegion
	ARCLENGTH: lengths
=#

function perm_repts( vlen::Vector{Float64},
                     n_old::Int64,
                     n_new::Int64,
                     tol::Float64
                    )::Vector{Int64}

    σ = collect(1:n_old)
    counter = 0
    i = 1

    while i ≤ n_old
        if vlen[i] ≤ tol
            σ[i] -= counter
            counter += 1
            i += 1
            if i ≤ n_old
                while vlen[i] ≤ tol
                    σ[i] = σ[i-1]
                    counter += 1
                    i += 1
                    (i>n_old) && break
                end
                if i ≤ n_old
                    σ[i] = σ[i-1]
                    i += 1
                end
            end
        else
            σ[i] -= counter
            i += 1
        end
    end

    if vlen[n_old] ≤ tol
        σ[n_old] = n_new
        i -= 1
        while vlen[i] ≤ tol
            σ[i] = n_new
            i -= 1
        end
    end
    
    return σ
end

function delete_repts(Ω::Matrix{Float64},
                      cuts::Matrix{Int64},
                      tol::Float64
                     )
    
    vlen = lengths(Ω)
    idx  = findall(x->x≥tol,vlen)
    id₀  = setdiff(1:size(Ω,1),idx)
    
    if ~isempty(id₀)
        Ω = Ω[idx,:]     
        if ~isempty(cuts)
            n_old = length(vlen)
            n_new = length(idx)
            σ = perm_repts(vlen,n_old,n_new,tol)
            cuts = σ[cuts]
        end
    end
    return Ω, cuts
end

function delete_repts(Dregs::Dict{Int64,DataRegion},
                      tol::Float64
                     )
    
    for k in keys(Dregs)
        Dregs[k].E, Dregs[k].idcuts = 
        delete_repts(Dregs[k].E, Dregs[k].idcuts, tol)
    end
    return Dregs
end 

=#