
  """
    J₂(x)

  Linear Map: (x₁,x₂) ↦ (x₂,-x₁).
  """
  J₂(x::Vector{Float64})::Vector{Float64} = [x[2]; -x[1]]

  """
    α(P,Q,R)

  Evaluation of the area functional at the triangle PQR.
  """
  α(P::Vector{Float64}, Q::Vector{Float64}, R::Vector{Float64}) =
  (Q[1]-P[1])*(R[2]-P[2]) + (Q[2]-P[2])*(P[1]-R[1])

  """
    α(Ω,p,q,r)

  Compute the area of the triangle PQR in polygonal region Ω, 
  where P = Ω[p], Q = Ω[q], R = Ω[r]
  """
  α(Ω::Matrix{Float64},p::Int64,q::Int64,r::Int64)::Float64 = 
  α(Ω[p,:],Ω[q,:],Ω[r,:])

  """
    α(Ω)

  Compute the area of a simply-connected polygonal region Ω: v₁,v₂,...,vₙ.

                ₙ₋₁ 
  α(Ω) = 1/2 ∑ det(vₖ,vₖ₊₁) + 1/2⋅det(vₙ,v₁)
                ₖ₌₁ 
  """
  function α(Ω::Matrix{Float64})::Float64 
    Σ   = sum([ Ω[k,:]'*J₂(Ω[k+1,:]) for k = 1:size(Ω,1)-1 ])
    Σ  += Ω[end,:]'*J₂(Ω[1,:])
    return 0.5Σ
  end