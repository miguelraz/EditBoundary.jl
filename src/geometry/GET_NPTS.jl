 # TODO - make a 1-liner
	function get_npts(R::DataRegion)::Int64
		n = size(R.E,1)
    	if ~isempty(R.H)
		 	for Hₖ in values(R.H)
		 		n += size(Hₖ,1)
		 	end
		end
		return n
	end