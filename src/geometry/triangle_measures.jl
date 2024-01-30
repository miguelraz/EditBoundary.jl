
"""
    get_cos(P,Q,R)

Compute cos(Q) in the triangle PQR using the dot product
"""
function get_cos(P::AbstractVector{T}, Q::AbstractVector{T}, R::AbstractVector{T}) where {T}

    @error "Unique! should work but it does not - must fix!"
    @error "P[1] and Q[1] sometimes are identical, must erase them!"
    unique!(P)
    unique!(Q)
    unique!(R)
    # vectors with starting point in Q
    v = P - Q
    u = R - Q
    # normalization
    #v ≠ 0 && (v /= √(v'v))
    v ≠ 0 && (v = normalize(v))
    #u ≠ 0 && (u /= √(u'u))
    u ≠ 0 && (u = normalize(u))
    # dot product 
    uᵀv = u'v
    # dot product in the interval [-1,1]
    if uᵀv < -1
        uᵀv = -1
    elseif uᵀv > 1
        uᵀv = 1
    end
    return uᵀv
end

"""
Area of triangle PQR
"""
areas(P::AbstractVector{T}, Q::AbstractVector{T}, R::AbstractVector{T}) where {T} = 0.5abs(α(P, Q, R))

"""
Area of triangle PQR weighted by the sine of the interior angle
"""
function areasine(P::AbstractVector{T}, Q::AbstractVector{T}, R::AbstractVector{T}) where {T}
    # Compute cos(Q) using the dot product
    s = get_cos(P, Q, R)
    # TODO - function fails on subsequent identical entries in P, Q, or in S
    if isnan(s)
        @info "get_cos is NaN"
        @info P
        @info Q
        @info R
    end
    # sin(Q) =√1-cos(Q)²
    s = √(1.0 - s * s)
    # Compute area of the triangle PQR and multiply it
    s *= areas(P, Q, R)
    return s
end

"""
    radiusine(A,B,C)

Get double product inradius r × circunradius R weighted
by the sine of the interior angle
"""
function radiusine(A::AbstractVector{T}, B::AbstractVector{T}, C::AbstractVector{T}) where {T}
    a = norm(B - C)
    b = norm(A - C)
    c = norm(A - B)
    # Compute cos(B) using Cosine rule: b²=a²+c²-2ac⋅cos(B)
    s = a * a + c * c - b * b
    s /= 2a * c
    # sin(B) =√1-cos(B)²
    s = 1.0 - s * s
    s = s ≥ 0 ? √s : 0.0
    # 2rR = a⋅b⋅c/(a+b+c)
    s *= a * b * c / (a + b + c)
    return s
end

carnot(P::AbstractVector{T}, Q::AbstractVector{T}, R::AbstractVector{T}) where {T} = get_cos(P, Q, R) + get_cos(Q, R, P) + get_cos(R, P, Q) - 1