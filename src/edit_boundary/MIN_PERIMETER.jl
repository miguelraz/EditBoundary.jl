
	function min_perimeter( xᵢₙᵢ::Vector{Float64}, 
							x₀::Vector{Float64}, 
						 	p₀::Float64, tolsmt::Float64, 
						 	itmax::Int64, itfmin::Int64
						 	)::Vector{Float64}

		opc = Optim.Options(f_tol = 1e-8,
		                    g_tol = 1e-3,
							iterations = itmax,
							outer_iterations = itfmin, 
		                    extended_trace = true);
		inner_optimizer = ConjugateGradient()

		# bounds for boundary neigborhood radius
		lower = x₀ .- tolsmt
		upper = x₀ .+ tolsmt
		# optimization
		optim_data = Optim.optimize(Optim.only_fg!(fg!), 
									lower, upper, xᵢₙᵢ,
								  	Fminbox(inner_optimizer), opc)

		return Optim.minimizer(optim_data)
 	end

	function min_perimeter(Ω::Matrix{Float64}, tolsmt::Float64)::Matrix{Float64}

		itmax  = 50
		itfmin = 5

		# perimeter
		p₀ = perim(Ω)
		# boundary neighborhood radius
		tolsmt *= p₀
		# rearrage initial contour
		x₀ = vec(Ω)
		# pertubatation of initial contour
		xᵢₙᵢ = [rand(LinRange(xᵢ-tolsmt,xᵢ+tolsmt,20)[2:end-1]) for xᵢ in x₀]
		# optimization
		xₒₚₜ = min_perimeter(xᵢₙᵢ, x₀, p₀, tolsmt, itmax, itfmin)
		# reshape 1D vector into two-column matrix
		Ω  = reshape(xₒₚₜ,length(xₒₚₜ) ÷ 2,2)
		return Ω
	end


	function min_perimeter!(R₀::DataRegion, R::DataRegion, tolsmt::Float64)

        R.E = min_perimeter(R₀.E,tolsmt)
        if  ~isempty(R.H)
      		for k in keys(R.H)
      			R.H[k] = min_perimeter(R₀.H[k],tolsmt)
      		end 
  		end
	end