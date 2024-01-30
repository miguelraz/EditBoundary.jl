#=
"""
    distseg(a,b,p)

Compute euclidean distance from the segment ab 
to the point p.
"""
function distseg(a::AbstractVector{T}, b::AbstractVector{T}, p::AbstractVector{T}) where T
    u = b - a
    v = p - a
    c = (u'v) / (u'u)
    if c > 1
        proy = b
    else
        proy = a
        (0 ≤ c ≤ 1) && (proy += c * u)
    end
    return norm(p - proy)
end
distseg(C::Matrix{Float64}, i::Int64, p::Int64, q::Int64) = @views distseg(C[p, :], C[q, :], C[i, :])
=#
