	
	C(n::Int64)::Vector{Int64} = [1:n;1]
	
	"""
	get4bnd(Ω,idcorners)
	"""
	function get4bnd(Ω::Matrix{Float64},idcorners::Vector{Int64})

		# initialize arrays
		vxlines = Float64[]
		vylines = Float64[]
		hxlines = Float64[]
		hylines = Float64[]
		# number of points in region
		nE = size(Ω,1)
		# lines for bottom and top sizes
		idx = bndpath(idcorners[1],idcorners[2],nE)
		vxlines = vcat(vxlines,Ω[idx,1])
		vylines = vcat(vylines,Ω[idx,2])
		push!(vxlines,NaN)
		push!(vylines,NaN)
		idx = bndpath(idcorners[3],idcorners[4],nE)
		vxlines = vcat(vxlines,Ω[idx,1])
		vylines = vcat(vylines,Ω[idx,2])
		# lines for right and left sizes
		idx = bndpath(idcorners[2],idcorners[3],nE)
		hxlines = vcat(hxlines,Ω[idx,1])
		hylines = vcat(hylines,Ω[idx,2])
		push!(hxlines,NaN)
		push!(hylines,NaN)
		idx = bndpath(idcorners[4],idcorners[1],nE)
		hxlines = vcat(hxlines,Ω[idx,1])
		hylines = vcat(hylines,Ω[idx,2])
		return vxlines, vylines, hxlines, hylines
	end

	"""
	draw_corners(E,i)
	"""
	function draw_corners(E::Matrix{Float64},i::Int64)

		return PlotlyJS.scatter(
					x = [E[i,1]], 
					y = [E[i,2]],
					mode = "markers",
			  		marker_symbol = "cross",
			  		marker_color = "green",
			  		marker_size = 10
	 			)
	end


	"""
	draw_bndsides(plt, E, IDcorners)
	"""
	function draw_bndsides(	plt::PlotlyJS.SyncPlot, 
							E::Matrix{Float64}, 
							IDcorners::Vector{Int64} 
						 )

		# coordinates of boundary sizes
 		vxlines, vylines, hxlines, hylines = 
 		get4bnd(E,IDcorners)
		# draw bottom and top sizes
		pltv = PlotlyJS.scatter(
				x = vxlines, y = vylines,
				mode = "lines",
				line_color = "blue",
				line_width = 2,
				hoverinfo = "none"
			)
		# draw right and left sizes
		plth = PlotlyJS.scatter(
				x = hxlines, y = hylines,
				mode = "lines",
				line_color = "orange",
				line_width = 2,
				hoverinfo = "none"
			)
		# update trace array
		addtraces!(plt,plth)
		addtraces!(plt,pltv)
	end

	"""
	fill_region(bx, by, c, iR, vis)
	"""
	function fill_region(bx, by, c, iR::Int64, vis::Bool = true)

		return PlotlyJS.scatter( 
					x = bx, y = by,
					mode = "lines",
					line_color = c,
					line_width = 0,
					fill = "toself",
					fillcolor = c,
					name = "mesh $iR",
					hoverinfo = "name",
					visible = vis
				)  
	end

	"""
	fill_region(Ω, label, c)
	"""
	function fill_region(Ω::Matrix{Float64}, label::String, c)

		idx = C(size(Ω,1))
		return PlotlyJS.scatter( 
					x = Ω[idx,1], 
					y = Ω[idx,2],
					mode = "lines",
					line_color = "blue",
					line_width = 1,
					fill = "toself",
					fillcolor = c,
					name = label,
					hoverinfo = "name"
				)  
	end

	"""
	fill_region(vtrace, R, c)
	"""
	function fill_region(vtrace::Vector{AbstractTrace}, 
						 R::DataRegion, c)

		iR = R.idreg
		label = "$iR"
		push!(vtrace, fill_region(R.E, label, c) )
		nH = length(R.H)
		if  nH ≠ 0
			for k in keys(R.H)
				label = "hole $k of region $iR"
				push!(vtrace, fill_region(R.H[k], label, "white") )
			end
		end
	end

	"""
	plot_region(Ω, idx, name, mode, fillreg, rcolor)
	"""
	function plot_region(Ω::Matrix{Float64},
						 idx::Vector{Int64},
						 name::String, 
						 mode::String,
						 fillreg::Bool,
						 rcolor
						 ) 
		
		if fillreg
			lwidth = 1
			lcolor = "blue"
			labels = string.(idx)
			hover  = "name+text"
		else
			lwidth = 2
			lcolor = "red"
			labels = string.(idx)
			hover  = "name+text"
		end

		DicLine = Dict(	:color => lcolor, 
						:width => lwidth,
						)
		DicPlt = Dict(	:x => Ω[idx,1],						
						:y => Ω[idx,2], 
						:mode => mode,	        		
		        		:line => DicLine,
		        		:text => labels,
		        		:name => name,
		        		:hoverinfo => hover
					)

		if  fillreg
			DicPlt[:fill] = "toself"
			DicPlt[:fillcolor] = rcolor
		end

		if mode == "markers+lines"
			DicPlt[:marker_color]  = fillreg ? "blue" : "red"
			DicPlt[:marker_symbol] = "circle"
			DicPlt[:marker_size]   = 1
		end

		return PlotlyJS.scatter(DicPlt)
	end

	"""
	plot_region_holes(vtrace, H, mode, fillreg)
	"""
	function plot_region_holes(	vtrace::Vector{AbstractTrace},
								H::Dict{Int64,Array{Float64}},
								mode::String,								
								fillreg::Bool
						 	 )
		for k in keys(H)
            idx  = C(size(H[k],1))
            name = "Hole $k"
            rcolor = "white"
            push!(vtrace, plot_region(H[k], idx, name, mode, fillreg, rcolor) )
		end
	end	

	"""
	plot_region_cuts(vtrace, Ω, idcuts)
	"""
	function plot_region_cuts(	vtrace::Vector{AbstractTrace},
								Ω::Matrix{Float64}, 
						 		idcuts::Matrix{Int64}
						 	 )

		xcuts = Float64[]
		ycuts = Float64[]
		for idcut in eachrow(idcuts)
			xcuts = vcat(xcuts,Ω[idcut,1])
			ycuts = vcat(ycuts,Ω[idcut,2])
			push!(xcuts,NaN)
			push!(ycuts,NaN)
		end
		plt = 	PlotlyJS.scatter(
					x = xcuts,
					y = ycuts,
					mode = "lines",
					line_dash  = "dashdot",
					line_color = "red",
					line_width = 4,
					hoverinfo = "skip"
				)
		push!(vtrace,plt)		
	end

	"""
	plot_region(vtrace, R, mode, fillreg, rcolor)
	"""
	function plot_region( 	vtrace::Vector{AbstractTrace}, 
							R::DataRegion, 
							mode::String,
							fillreg::Bool,
							rcolor
						)

		iR   = R.idreg
		idx  = C(size(R.E,1))
		name = R.name*" "
		iR ≠ 0 && ( name*= string(iR) )

		push!(vtrace, plot_region(R.E, idx, name, mode, fillreg, rcolor) )
		~isempty(R.H) && plot_region_holes(vtrace, R.H, mode, fillreg)
		~isempty(R.idcuts) && plot_region_cuts(vtrace, R.E, R.idcuts)
	end

	"""
	plt = plot_region(R)
	"""
	function plot_region(R::DataRegion)

		iR   = R.idreg
		name = R.name*" "
		vtrace = AbstractTrace[]
		(iR ≠ 0) && ( name *= string(iR) )
		rcolor = "#40B4BF"
		plot_region(vtrace, R, "markers+lines", true, rcolor)
		layoutC[:title] = name
		return PlotlyJS.plot(vtrace, layoutC)	
	end

	"""
	plt = plot_region(R,idcorners,c)
	"""
	function plot_region(R::DataRegion, idcorners::Vector{Int64}, c)
		
		# region name
		name = R.name*" "
		(R.idreg ≠ 0) && ( name *= string(R.idreg) )
		# get coordiantes of the four sizes
		# two vertical curves and two horizontal curves
		vxlines, vylines, hxlines, hylines = get4bnd(R.E,idcorners)
		# create empty trace for figure
		vtrace = AbstractTrace[]
		# draw interior of the region
		plot_region(vtrace, R, "markers+lines", true, c)
		# draw bottom and top sizes
		pltv = PlotlyJS.scatter(
				x = vxlines, y = vylines,
				mode = "lines",
				line_color = "blue",
				line_width = 2,
				hoverinfo = "none"
			)
		# draw right and left sizes
		plth = PlotlyJS.scatter(
				x = hxlines, y = hylines,
				mode = "lines",
				line_color = "orange",
				line_width = 2,
				hoverinfo = "none"
			)
		# draw corners
		pltc = PlotlyJS.scatter(
				x = R.E[idcorners,1], 
				y = R.E[idcorners,2],
				mode = "markers",
				marker_symbol = "cross",
		 		marker_color = "green",
		 		marker_size = 10,
				text = string.(idcorners),
				hoverinfo = "text"
			)
		# update trace array
		push!(vtrace,plth)
		push!(vtrace,pltv)
		push!(vtrace,pltc)
		# set title
		layoutC[:title] = name
		# draw figure
		return PlotlyJS.plot(vtrace, layoutC)
	end

	"""
	plt = plot_region(R₀,R)
	"""
	function plot_region(R₀::DataRegion, R::DataRegion)
		vtrace = AbstractTrace[]
		fill_region(vtrace, R₀, "#40B4BF")
		plot_region(vtrace, R, "markers+lines", false, "red" )
		layoutC[:title] = "Approximation of "*R₀.name
		return PlotlyJS.plot(vtrace, layoutC)
	end


	"""
	plot_region(Dreg)
	"""
	function plot_region(Dreg::Dict{Int64,DataRegion})

		name    = Dreg[1].name
		nR 	    = length(Dreg)
	    vtrace  = AbstractTrace[]
	    rcolors = region_colors(nR)
	    for iR = 1:nR
	    	fill_region(vtrace, Dreg[iR], rcolors[iR])
	    end
	    layoutR[:title] = name*" split into $nR regions"
	    return PlotlyJS.plot(vtrace,layoutR)
	end


	"""
	update_plot_regions!(plt,R)
	"""
	function update_plot_regions!(plt::PlotlyJS.SyncPlot, R::DataRegion)

		# update plot data
		idx = C(size(R.E,1))
		restyle!(	plt, 1, 
					x = (R.E[idx,1],), 
					y = (R.E[idx,2],),
					text = (string.(idx),)
				)
		if ~isempty(R.H)
			for k = 1:length(R.H)
				idx = [1:size(R.H[k],1);1]
				restyle!(	plt, k+1, 
							x = (R.H[k][idx,1],), 
							y = (R.H[k][idx,2],),
							text = (string.(idx),)
						)
			end
		end
	end


	"""
	update_plot_region!(plt,R,idcorners)
	"""
	function update_plot_region!(
				plt::PlotlyJS.SyncPlot,
				R::DataRegion,
				idcorners::Vector{Int64}
			)

		# region name
		name = R.name*" "
		(R.idreg ≠ 0) && ( name *= string(R.idreg) )
		# boundary indexes
		idx = C(size(R.E,1))
		# array of coordiantes for the cuts
		xcuts = Float64[]
		ycuts = Float64[]
		for idcut in eachrow(R.idcuts)
			xcuts = vcat(xcuts,R.E[idcut,1])
			ycuts = vcat(ycuts,R.E[idcut,2])
			push!(xcuts,NaN)
			push!(ycuts,NaN)
		end
		# array of coordinates for the four sizes
		vxlines, vylines, hxlines, hylines = get4bnd(R.E, idcorners)
		# update boundary points
		restyle!(	plt, 1, 
					x = (R.E[idx,1],), 
					y = (R.E[idx,2],),
					text = (string.(idx),)
				)
		# update cut lines
		restyle!(	plt, 2,
					x = (xcuts,), 
					y = (ycuts,),
				)
		# update bottom and top sizes
		restyle!(	plt, 3, 
					x = (vxlines,), 
					y = (vylines,)
				)
		# update right and left sizes
		restyle!(	plt, 4, 
					x = (hxlines,), 
					y = (hylines,)
				)
		# update corners
		restyle!(	plt, 5, 
					x = (R.E[idcorners,1],), 
					y = (R.E[idcorners,2],)
				)
		# update title
		relayout!(layoutC, title = name)
	end

	"""
	update_plot_regions!(plt,Ω,nh)
	"""
	function update_plot_regions!(
				plt::PlotlyJS.SyncPlot,
				Ω::Matrix{Float64},
				np::Int64
			)
		# number of points in boundary
		idx = C(size(Ω,1))
		# update plot data
		restyle!(	plt, np, 
					x = (Ω[idx,1],), 
					y = (Ω[idx,2],),
					text = (string.(idx),)
				)	
	end

	"""
	update_plot_regions!(plt,R)
	"""
	function update_plot_regions!(
				plt::PlotlyJS.SyncPlot,
				R::DataRegion
			)
		# number of holes
		nH = length(R.H)
		# update exterior boundary
		update_plot_regions!(plt,R.E,1)
		# update interior boundaries
		~isempty(R.H) && foreach(k->update_plot_regions!(plt,R.H[k],k+1),1:nH)
	end

	"""
	update_plot_regions!(plt,R,np)
	"""
	function update_plot_regions!(
				plt::PlotlyJS.SyncPlot,
				R::DataRegion,
				np::Int64
			)
		# number of holes
		nH = length(R.H)
		# update exterior boundary
		update_plot_regions!(plt,R.E,np+2)
		# update interior boundaries
		~isempty(R.H) && foreach(k->update_plot_regions!(plt,R.H[k],np+k+2),1:nH)
	end

	"""
	update_plot_regions!(plt,tab,R,infovec,nH₀)
	"""
	function update_plot_regions!(
				plt::PlotlyJS.SyncPlot,
				tab::PlotlyJS.SyncPlot,
				R::DataRegion,
				infovec::Vector{String},
				nH₀::Int64,
				name::String = ""
			)

    	# get new table info
		labels, newinfovec = basic_region_info(R)
		isempty(name) && ( newinfovec[1] = "Approx")
		# update table
		tabvalues = [ labels infovec newinfovec]
		restyle!(tab, 1, cells_values = (tabvalues,) )
		# update plot data
		update_plot_regions!(plt,R,nH₀)
	end


	"""
	update_tab_regions!(tab,Dreg,labels)
	"""
	function update_tab_regions!(
				tab::PlotlyJS.SyncPlot,
				Dreg::Dict{Int64,DataRegion},
				labels::Vector{String}
			)

    	# get new table info
		tabvalues = labels
		nH₀ = length(Dreg[0].H)
		for k = 0:3 
			newinfo   = basic_region_info(Dreg[k])[2]
			tabvalues = hcat(tabvalues, newinfo )
		end
		# update table
		restyle!(tab, 1, cells_values = (tabvalues,) )
	end


	"""
	update_plot_region!(plt, tab, αplt₀, rplt₀, μplt, R₀, R, 
						labels, infovec₀, infovec, αvec)
	"""
	function update_plot_region!(
				plt::PlotlyJS.SyncPlot,
				tab::PlotlyJS.SyncPlot,
				αplt₀::PlotlyJS.SyncPlot, 
				μplt::PlotlyJS.SyncPlot, 
				R₀::DataRegion,
				R::DataRegion,
				labels::Vector{String},
				infovec₀::Vector{String},
				infovec::Vector{String},
				αvec::Vector{Float64}
			)
		newtab = region_table(labels,[infovec₀ infovec])
		αplt   = plot_measure(αvec,"Area Plot Approx")
        newplt = plot_region(R₀,R)
		newμplt  = [αplt₀ αplt]
		relayout!(newμplt,  template = "plotly_white",
							height = 500,
							showlegend = false,
							hovermode  = false)
		react!(plt, newplt.plot.data, newplt.plot.layout)
		react!(tab, newtab.plot.data, newtab.plot.layout)
		react!(μplt, newμplt.plot.data, newμplt.plot.layout)
 	end

 	"""
 	save_region_plot(R₀,R,filepath)
 	"""
 	function save_region_plot(R₀::DataRegion, R::DataRegion, filepath::String)

	    CairoMakie.activate!()
		fig = Figure()
		str = "Approximation of "*R₀.name
		region_window(fig,str,1)
		if isempty(R₀.H)
			p = Polygon(p2f(R₀.E))
		else
			p = Polygon( p2f(R₀.E), [ p2f(R₀.H[k]) for  k in Int64.(keys(R₀.H)) ])
		end
		poly!(p, color = "#40B4BF")
		xlines = Float64[]
		ylines = Float64[]
		xlines = vcat(xlines, R.E[:,1])
		xlines = vcat(xlines, R.E[1,1])
		ylines = vcat(ylines, R.E[:,2])
		ylines = vcat(ylines, R.E[1,2])
		push!(xlines,NaN)
		push!(ylines,NaN)
		if ~isempty(R.H)
			for Hₖ in values(R.H)
				xlines = vcat(xlines, Hₖ[:,1])
				xlines = vcat(xlines, Hₖ[1,1])
				ylines = vcat(ylines, Hₖ[:,2])
				ylines = vcat(ylines, Hₖ[1,2])
				push!(xlines,NaN)
				push!(ylines,NaN)
			end
		end
		scatterlines!(xlines, ylines,
	                 color=:red, 
	                 markercolor =:red, 
	                 marker = :circle, 
	                 markersize = 2,
	                 linewidth = 0.3,
         )
    	CairoMakie.save( filepath*".pdf", fig, pt_per_unit = 2)
    	GLMakie.activate!()
 	end