function remove_holes!(H::Dict{Int64,Matrix{Float64}})

    counter = 1
    nH = length(H)
    display("The Region has more $nH holes")
    display("Only the 50 largest holes are keep")
    idholes = Int64.(keys(H))
    hareas = [α(H[iH]) for iH in idholes]
    idh = sortperm(hareas; rev=true)
    list_holes = idholes[idh[1:50]]

    copyH = Dict(k => copy(H[list_holes[k]]) for k = 1:50)
    empty!(H)
    for k = 1:50
        H[k] = copyH[k]
    end
end