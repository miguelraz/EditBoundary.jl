# TODO - implement Bentley-Ortmann or better algorithm
function seg_intersect(p::Vector{Float64},
    q::Vector{Float64},
    r::Vector{Float64},
    s::Vector{Float64},
    tol::Float64=1e-8)

    D = (q[1] - p[1]) * (s[2] - r[2]) - (q[2] - p[2]) * (s[1] - r[1])

    if abs(D) ≤ tol
        return 0
    end

    u = (r[1] - p[1]) * (q[2] - p[2]) - (r[2] - p[2]) * (q[1] - p[1])
    u /= D
    v = (r[1] - p[1]) * (s[2] - r[2]) - (r[2] - p[2]) * (s[1] - r[1])
    v /= D

    if (0.0 ≤ u ≤ 1.0) & (0.0 ≤ v ≤ 1.0)
        iflag = 1
    else
        iflag = 0
    end

    return iflag
end

function folding(n::Int64,
    x::Vector{Float64},
    y::Vector{Float64},
    label::String
)

    iflag = false

    p = zeros(2)
    q = zeros(2)
    r = zeros(2)
    s = zeros(2)

    for k = n-1:-1:3

        p[1] = x[k]
        p[2] = y[k]
        q[1] = x[k+1]
        q[2] = y[k+1]

        i₁ = 1
        i₂ = k - 2

        (k == n - 1) && (i₁ = 2)

        for i = i₁:i₂

            r[1] = x[i]
            r[2] = y[i]
            s[1] = x[i+1]
            s[2] = y[i+1]

            if isone(seg_intersect(p, q, r, s))
                label *= "$i "
                iflag = true
            end
        end
    end

    iflag && display(label)

    return iflag
end

function folding(R::DataRegion, iflag::Bool=false)
    x = R.E[:, 1]
    y = R.E[:, 2]
    nΩ = size(R.E, 1)
    label = "self-intersection: "
    labelE = label * "exterior boundary → segments "
    folding(nΩ, x, y, labelE) && (iflag = true)

    if ~isempty(R.H)
        for k in keys(R.H)
            x = R.H[k][:, 1]
            y = R.H[k][:, 2]
            nΩ = size(R.H[k], 1)
            labelH = label * " hole $k → segments "
            folding(nΩ, x, y, labelH) && (iflag = true)
        end
    end

    return iflag
end