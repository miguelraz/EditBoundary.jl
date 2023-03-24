
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


  """
  cell_index_bnd(idc, idx)
  """
  function cell_index_bnd(idc::Matrix{Int64}, idx::Vector{Int64})
    
      list = Array{Int64}([])
       @inbounds for i  in idx
          id  = findall(x->x==i,idc)
          for k in eachindex(id)
              push!(list, id[k][1])
          end
      end
      return unique!(list)
  end       																		

	"""
	infoα(pts, idc, list, tolcvx)

	Get the minimum area of the mesh triangles and the number of non-convex quads.

    INPUT
        pts   -->  coordinate matrix of mesh points

        idc   -->  index matrix of points per quad

        list  -->  list of slected quads

    OUTPUT

        nc    -->  number of non-convex quads

        αmin  -->  minimum area of the mesh triangles

	"""
  function infoα(pts::Matrix{Float64}, 
                 idc::Matrix{Int64}, 
                 list::Array{Int64},
                 tolcvx::Float64
                 )

    nc = 0
    ncvec = Vector{Bool}()
    αmin  =  Inf
    αmax₋ = -Inf

    I3 = [3,4,1]
    I4 = [4,1,2]
    αTriangles = zeros(4)

    # loop on the selected mesh cells
    @inbounds for k in list
    
      αTriangles .= [α(pts[idc[k,I4],:]),
                    α(pts[idc[k,1:3],:]),
                    α(pts[idc[k,2:4],:]),
                    α(pts[idc[k,I3],:])]
      # minimum area of the four triangles 
      am = minimum(αTriangles)
      # maximum negative area of the four triangles
      for αᵢ in αTriangles
        if αmax₋ < αᵢ < 0
           αmax₋ = αᵢ
        end
      end 

      # update minimum triangle area and number of non-convex cells
      (am < αmin) && (αmin = am)
      if 0.5am < tolcvx 
          nc += 1
          push!(ncvec,false)
      else
          push!(ncvec,true)
      end
    end
    αmin  *= 0.5
    αmax₋ *= 0.5
    (αmax₋ == -Inf) && (αmax₋ = tolcvx)
    
    return nc, αmin, αmax₋, ncvec
  end

  """
  infoα(pts,idc,tolcvx)
  """
  function infoα(pts::Matrix{Float64}, 
                 idc::Matrix{Int64}, 
                 tolcvx::Float64
                 )

    list = collect(1:size(idc,1))
    return infoα(pts, idc, list, tolcvx)
  end

  """
  infoα(pts, idc,m, n)
  """
  function infoα(pts::Matrix{Float64}, 
                 idc::Matrix{Int64}, 
                 m::Int64, 
                 n::Int64,
                 tolcvx::Float64
                 )

    corners = [1,m,m+n-1,2m+n-2]
    corner_cells = cell_index_bnd(idc,corners)
    noncorner_cells = setdiff(1:size(idc,1),corner_cells)

    return infoα(pts, idc, noncorner_cells, tolcvx)
  end