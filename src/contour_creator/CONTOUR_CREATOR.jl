    function contour_creator( bnd::Dict{Int64,VecPts} )

        n  = length(bnd)
        idreg   = 0
        idcuts  = Array{Int64}(undef,0,2)
        name    = "polygon_"*format(now(),"dd-u-yy-HHMM")
        H = Dict{Int64,Matrix{Float64}}()
        if n > 1
            for k = 1:n-1
                H[k] = obs2xy(bnd[k])
            end
        end
         
        R = DataRegion(obs2xy(bnd[0]),H,idcuts,idreg,name)

        delim = Sys.iswindows() ? "\\" : "/"
        dirpath = pwd()*delim*"tests"*delim
        save_region(R,dirpath)
        display("region saved in tests folder as: "*name)
    end

    function contour_creator()

        counter = GLMakie.Node(0)
        pts     = GLMakie.Node(Point2f0[])

        display("Select an option")
        display("[1] load an image")
        display("[2] load a region")
        display("[ENTER] use background grid")
        sleep(1)
        opc = strip(readline())
        @assert opc in ["","1","2"] "invalid option"

        if opc == "2"
            R   = get_region()
            Dpts, Dflpts, list = bnd_dict(R)
            counter[] = 1 + length(R.H)
        else
            Dpts    = Dict{Int64, Observable{VecPts} }()
            Dflpts  = Dict{Int64, Observable{VecPts} }()
            opc == "1" && ( img = load(assetpath(get_path_img())) )
        end

        str =   "L-Click add pt | "*
                "R-Click delete pt | "*
                "C close curve | "*
                "R reset view | "*
                "S save"
        fig = Figure()
        ax  = bnd_window(fig, str)
        ax.aspect = DataAspect()

        if opc == "1"
            image!(fig[1, 1], rotr90(img))
        elseif opc == "2"
            for k in keys(Dpts)
                scatterlines!(Dpts[k],
                     color=:blue, 
                     markercolor =:red, 
                     marker = :circle, 
                     markersize = 5
                     )
                lines!(Dflpts[k], color=:blue)
            end
        else
            xlims!(ax, 0, 10)
            ylims!(ax, 0, 10)
        end
        
        display(fig)

        on(events(fig).keyboardbutton) do event
            
            if  event.action in (Keyboard.press, Keyboard.repeat)
                # press R to reset view 
                if event.key == Keyboard.r  
                    reset_limits!(ax)
                # press S to save the polygon
                elseif event.key == Keyboard.s
                    
                    bnd  = Dict(k => Dpts[k][] for k in keys(Dpts))
                    n  = length(bnd)
                    idcuts  = Matrix{Int64}(undef,0,2)
                    H = Dict{Int64,Matrix{Float64}}()
                    if n > 1
                        for k = 1:n-1
                            H[k] = obs2xy(bnd[k])
                        end
                    end
                    E = obs2xy(bnd[0])
                    R = DataRegion(E,H,idcuts,0,"newregion")
                    ask_save_region(R)
                # press C to close the polygon
                elseif event.key == Keyboard.c
                    # update dictionaries
                    k₊ = copy(counter[])
                    Dflpts[k₊] = GLMakie.Node( [ first(Dpts[k₊][]), last(Dpts[k₊][]) ] )
                    # draw closed polygon
                    lines!(Dflpts[k₊], color=:blue)
                    # update counter
                    counter[] += 1
                    # save region
                    if ~isempty(Dpts) 
                        bnd = Dict(k => Dpts[k][] for k in keys(Dpts))
                        contour_creator(bnd)
                    end
                end
            end
            return false
        end

        on(events(ax.scene).mousebutton, priority = 2) do event

            # left click to add a point
            if ispressed(ax.scene,Mouse.left)

                new_point = [mouseposition(ax.scene)]

                k₊ = copy(counter[])
                if haskey(Dpts,k₊)
                    Dpts[k₊][] = [ Dpts[k₊][]; new_point]
                else
                    Dpts[k₊] = GLMakie.Node(new_point)
                    scatterlines!(  Dpts[k₊], 
                                color=:blue, 
                                markercolor =:red, 
                                marker = :circle, 
                                markersize = 5
                                )  
                end

                return Consume(true)
            end
            
            # right click to delete a point
            if ispressed(ax.scene,Mouse.right) 
                
                new_point = [mouseposition(ax.scene)]
                pt = new_point[1][1:2]

                list = collect(keys(Dpts))
                Diₘᵢₙ = Dict{Int64,Int64}()
                Ddₘᵢₙ = Dict{Int64,Float64}()

                for k in keys(Dpts)
                   Ω  = obs2xy(Dpts[k])
                   nΩ = size(Ω,1)
                   iₖ = argmin( [ norm(Ω[i,:]-pt) for i =1:nΩ ] )
                   Diₘᵢₙ[k] = iₖ
                   Ddₘᵢₙ[k] = norm(Ω[iₖ,:]-pt) 
                end

                kₘᵢₙ = list[ argmin( [ Ddₘᵢₙ[k] for k in list] ) ]
                iₘᵢₙ = Diₘᵢₙ[kₘᵢₙ]
                nΩ = length(Dpts[kₘᵢₙ][])

                if isone(iₘᵢₙ)
                    idx = 2:nΩ
                elseif iₘᵢₙ == nΩ
                    idx = 1:nΩ-1
                else
                    idx = union(1:iₘᵢₙ-1,iₘᵢₙ+1:nΩ)
                end

                Dpts[kₘᵢₙ][] = Dpts[kₘᵢₙ][][idx]
                if  ~isempty(Dflpts) & ( isone(iₘᵢₙ) || iₘᵢₙ == nΩ )
                    Dflpts[kₘᵢₙ][] = [ first(Dpts[kₘᵢₙ][]), last(Dpts[kₘᵢₙ][]) ]
                    # draw closed polygon
                    lines!(Dflpts[kₘᵢₙ], color=:blue)
                end

                return Consume(true)
            end
            
            return Consume(false)
        end

        return Dict(k => Dpts[k][] for k in keys(Dpts))
    end

    function contour_creator_menu()

        display("Contour Creator: Program for interactive creation of polygonal regions")
        display("Press ENTER to create a new region or")
        display("Press H to add a hole to a region")
        sleep(1)
        str = replace(readline()," "=>"")
        if isempty(str)
            contour_creator()
        elseif str in ["h","H"]
            add_hole()
        end
    end
