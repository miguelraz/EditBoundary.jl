
"""
    del_repts!(R::DataRegion)

Remove repeated points of the region, incluiding holes.
"""
function del_repts!(R::DataRegion)
    R.E = unique(R.E, dims=1)
    for k in keys(R.H)
        R.H[k] = unique(R.H[k], dims=1)
    end
end