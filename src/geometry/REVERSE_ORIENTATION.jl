	"""
	reverse_orientation!(Ω)

	Reverse orientation of a clockwise oriented polygon 
	using its triangle areas
	"""
	function reverse_orientation!(Ω::Matrix{Float64})
		# compute the signed area of the region
		αΩ = α(Ω)
		# reverse orientation for negative area regions
		if  αΩ < 0
			display("the orientation is reversed")
			Ω[2:end,:] .= Ω[end:-1:2,:]
		end
	end

	"""
	reverse_orientation!(R)

	Reverse orientation of a polygonal region using its triangle areas
	"""
	function reverse_orientation!(R::DataRegion)

		reverse_orientation!(R.E)
		if ~isempty(R.H)
			for k in keys(R.H)
				reverse_orientation!(R.H[k])
			end
		end
	end