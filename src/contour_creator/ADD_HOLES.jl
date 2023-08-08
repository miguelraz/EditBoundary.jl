    get_centroid(Ω::Matrix{Float64}) =
    vec(sum(Ω;dims=1)/size(Ω,1)) 


    function get_centroid(Ω::VecPts)
        c = zeros(eltype(Ω[1]),2)
        for r in eachrow(Ω)
            c += r[1]
        end
        c /= length(Ω)
        return c
    end

    #=
	function add_hole(	R::DataRegion,
						H::Matrix{Float64}
					 )
        
        nH = length(R.H)
        # delimiter
        delimiter = Sys.iswindows() ? "\\" : "/"
        # figure layout
        str =   "red hole | "*
                "R-click move hole | "*
                "R reset view | "*
                "S save"
        fig = Figure()
        ax  = bnd_window(fig,str)
        ax.aspect = DataAspect()
        # text box for the scaling factor
        tb = Textbox(fig[2, 1], placeholder = "Scaling factor ≤ 1",
                    validator = Float64, tellwidth = false)
        # observable for scaling factor
        fesc = GLMakie.Node(1.0)
        ###################################################
        # create dictionary of observables for the region #
        ###################################################
        Dpts   = Dict{Int64, Observable{VecPts} }()
        Dpts₁  = Dict{Int64, Observable{VecPts} }()
        # exterior boundary
        Dpts[0]  = bnd2obs(R.E)
        Dpts₁[0] = bnd2obs1(R.E)
        # interior boundary
        if  nH > 0
            for i = 1:nH
                Dpts[i]  = bnd2obs(R.H[i])
                Dpts₁[i] = bnd2obs1(R.H[i])
            end
        end
        # centroid of the exterior boundary
        reg_centroid  = get_centroid(R.E)
        # maximum distance from the region centroid 
        # to its exterior boundary
        rₘₐₓ = -Inf
        for pt in eachrow(R.E)
            rₘₐₓ = max(rₘₐₓ,norm(reg_centroid-pt))
        end
        # scale the hole
        H .*= rₘₐₓ*scaleinB₂(H)
        # centroid of the scaled hole 
        new_centroid = get_centroid(H)
        # translation of the hole
        newpos = reg_centroid - new_centroid
        for r in eachrow(H)
            r .+= newpos
        end
        # add new hole to the dictionary
        Dpts[nH+1]  = bnd2obs(H)
        Dpts₁[nH+1] = bnd2obs1(H)
        # draw region
        for i = 0:nH
            scatterlines!(Dpts[i],
                 color=:blue, 
                 markercolor =:blue, 
                 marker = :circle, 
                 markersize = 0
                 )
            scatterlines!(Dpts₁[i],
                 color=:blue, 
                 markercolor =:blue, 
                 marker = :circle, 
                 markersize = 0
                 )
        end
        # draw new hole
        scatterlines!(Dpts[nH+1], 
                     color=:red, 
                     markercolor =:red, 
                     marker = :circle, 
                     markersize = 1
                     )
        scatterlines!(Dpts₁[nH+1], 
                     color=:red, 
                     markercolor =:red, 
                     marker = :circle, 
                     markersize = 1
                     )
        # show the region and the new hole
        display(fig)

        # event for mouse interaction
        on(events(ax.scene).mousebutton, priority = 2) do event
            # left click to move hole at the new point
            if ispressed(ax.scene,Mouse.right) 
                # update centroid at the point clicked by mouse
                old_centroid = get_centroid(Dpts[nH+1][])
                new_centroid = [mouseposition(ax.scene)][1]
                newpos = new_centroid - old_centroid
                # translation of the hole            
                Dpts[nH+1][]  = [ r[1]+newpos for r in eachrow(Dpts[nH+1][]) ]
                Dpts₁[nH+1][] = [first(Dpts[nH+1][]),last(Dpts[nH+1][])]
                return Consume(true)
            end
        	return Consume(false)

        end
        # event for textbox
        on(tb.stored_string) do s
            # update scaling factor
            fold = copy(fesc[])
            fesc[] = parse(Float64, s)
            fnew = fesc[]/fold
            # get centroid before scaling
            old_centroid = get_centroid(Dpts[nH+1][])
            # update hole
            Dpts[nH+1][] = [ fnew*r[1] for r in eachrow(Dpts[nH+1][])]
            # get centroid after scaling
            new_centroid = get_centroid(Dpts[nH+1][])
            newpos = old_centroid - new_centroid
            # update hole
            Dpts[nH+1][]  = [ r[1]+newpos for r in eachrow(Dpts[nH+1][])]
            Dpts₁[nH+1][] = [first(Dpts[nH+1][]),last(Dpts[nH+1][])]
        end
        
        on(events(fig).keyboardbutton) do event 
            if  event.action in (Keyboard.press, Keyboard.repeat)
                # Press R to reset view
                if event.key == Keyboard.r 
                    reset_limits!(ax)
                # Press S to save region
                elseif event.key == Keyboard.s
                    nH = length(Dpts)-1
                    R.H[nH] = obs2bnd(Dpts[nH])

                    filepath = Gtk_save_dialog("save region",R.name*".geo")
                    dirpath = join(split(filepath,delimiter)[1:end-1].*delimiter)
                    R.name = get_name(filepath)[1]
                    save_region(R,dirpath)
                end
            end
        end

        return Dpts
	end

    function add_hole()
        display("Press ENTER to choose a region")
        sleep(1)
        readline()
        R = get_region()
        display("Now press ENTER to choose a hole")
        sleep(1)
        readline()
        Rnew = get_region()
        add_hole(R,Rnew.E)
    end
    =#