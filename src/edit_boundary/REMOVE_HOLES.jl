	"""
	remove_holes!(H)
	"""
	function remove_holes!(H::Dict{Int64,Matrix{Float64}})

		counter = 1
		nH = length(H)
		display("The Region has more $nH holes")
		display("Only the 50 largest holes are keep")
		idholes = Int64.(keys(H))
		hareas  = [α(H[iH]) for iH in idholes]
		idh     = sortperm(hareas; rev = true)
		list_holes = idholes[idh[1:50]] 

		copyH = Dict( k => copy(H[list_holes[k]]) for k = 1:50 )
		empty!(H)
		for k = 1:50
			H[k] = copyH[k]
		end
	end


	"""
	remove_holes!(plt, tab, αplt₀, μplt, R₀, R, infovec)

	Routine for interactive edition of polygons by mouse clicks
	"""
	function remove_holes!(
				plt::PlotlyJS.SyncPlot,
				tab::PlotlyJS.SyncPlot,
				αplt₀::PlotlyJS.SyncPlot, 
				μplt::PlotlyJS.SyncPlot, 
				R₀::DataRegion,
				R::DataRegion,
				infovec::Vector{String}
				)

		Rcopy = copy_region(R)
		nH = length(R.H)
		idholes = Int64.(keys(R.H))

		display("The region has $(nH) holes")
		display("Introduce an option")
		display("[Enter] return")
		display("[1] Remove holes by number")
		display("[2] Remove the smallest holes")
		display("[3] Remove all holes")
		sleep(1)
		task = replace(readline()," "=>"")

		if task == "1"

				display("Introduce hole numbers separated by commas")
				sleep(1)
				str = readline()
				str  = replace( str," "=>"")

				list_del  = parse.(Int64, split(str, ",") )
				list_keep = setdiff(idholes,list_del)
				nkeep = length(list_keep)

				copyH = Dict(k => copy(R.H[list_keep[k]]) for k = 1:nkeep)
				empty!(R.H)
				for k = 1:nkeep
					R.H[k] = copyH[k]
				end
		elseif task == "2"

				display("Introduce the number of small holes to remove or")
				display("Press ENTER to exit")
				sleep(1)
				str = replace(readline()," "=>"")
				if ~isempty(str)
					nr = parse(Int64,str)
					@assert nr ≤ nH "Can't remove more than $nH holes"
					
					idholes = Int64.(keys(R.H))
					hareas  = [α(R.H[iH]) for iH in idholes]
					idh     = sortperm(hareas; rev = true)
					nkeep   = nH-nr
					list_keep = idholes[idh[1:nkeep]] 

					copyH = Dict( k => copy(R.H[list_keep[k]]) for k = 1:nkeep )
					empty!(R.H)
					for k = 1:nkeep
						R.H[k] = copyH[k]
					end
				end 
		elseif task == "3"
				empty!(R.H)
		end
		if task in ["1","2","3"]
			R₁ = copy_region(R)
			del_pts!(areasine, R₁, 0.01)
			αvec = triangle_areas_sorted(R₁)
			labels, newinfovec = basic_region_info(R)
			update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
								labels, infovec, newinfovec, αvec)
		end

		sleep(1)
		display("Press ENTER to update the region or")
		display("Press N to use the previous region")
		sleep(1)
		str = replace(readline()," "=>"")
		if str in ["n","N"]
			empty!(R.H)
			for k ∈ keys(Rcopy.H)
				R.H[k] = Rcopy.H[k]
			end
			R₁ = copy_region(R)
			del_pts!(areasine, R₁, 0.01)
			αvec = triangle_areas_sorted(R₁)
			labels, newinfovec = basic_region_info(R)
			update_plot_region!(plt, tab, αplt₀, μplt, R₀, R, 
								labels, infovec, newinfovec, αvec)
		end

	end