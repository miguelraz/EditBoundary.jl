#############################################
#  Julia Packages
#############################################
import  Base.range
# Text input and output
using 	Printf, 
    	DelimitedFiles,
    	FileIO
using   Base64: stringmime
using   Dates: format, now
# Interactivity
using	GLMakie,
        Makie.GeometryBasics,
        Colors,
        WebIO, 
	PlotlyJS
# Pop up a window to select a file
using   Gtk
using   IJulia: clear_output	
# Linear algebra
using   LinearAlgebra.BLAS:     nrm2, 
                                dot, 
                                blascopy!, 
                                scal!
using   LinearAlgebra: norm
# Optimization
using   Optim
#############################################
# UNAMalla Packages
#############################################
include("data_structures/DATA_UNAMALLA.jl")

include("geometry/GET_NPTS.jl")
include("geometry/AREA.jl")
include("geometry/FOLDING.jl")
include("geometry/DISTSEG.jl")
include("geometry/SCALEINB2.jl")
include("geometry/TRIANGLE_AREAS.jl")
include("geometry/TRIANGLE_MEASURES.jl")
include("geometry/REGION_INFO.jl")
include("geometry/CHECK_HOLES.jl")
include("geometry/FG_PERIMETER.jl")
include("geometry/REVERSE_ORIENTATION.jl") 

include("IO/GET_NAME.jl")
include("IO/GET_PATH.jl")
include("IO/REGIONIO.jl")
include("IO/DELETE_REPTS.jl")
include("IO/COPY_REGION.jl")
include("IO/DEPURATION.jl")
include("IO/GET_REGION.jl")

include("contour_creator/OBS2XY.jl")
include("contour_creator/BND_WINDICT.jl")
include("contour_creator/ADD_HOLES.jl")
include("contour_creator/CONTOUR_CREATOR.jl")

include("plot/PLOT_LAYOUT.jl")
include("plot/PLOT_MEASURE.jl")
include("plot/PLOT_REGION.jl")
include("plot/MENUS.jl")
include("plot/REGION_TABLES.jl")
include("plot/MEASURE_TABLE.jl")
include("plot/SHOW_REGION_INFO.jl")
include("plot/THEREHOLD_TABLE.jl")
include("plot/PLOT_SIMP_PER.jl")

include("edit_boundary/POINT_ELIMINATION.jl")
include("edit_boundary/MIN_PERIMETER.jl")
include("edit_boundary/AUTO_SIMPLIFICATION.jl")
include("edit_boundary/REMOVE_HOLES.jl")
include("edit_boundary/EDIT_BOUNDARY.jl")
include("edit_boundary/GET_TOLERANCES_SLIDER_VALUES.jl")

#=
# set directory path 
push!(LOAD_PATH,pwd())
# load scripts
include("Load_EditBoundary.jl")
# load contour
R = read_region()
# contour test
depuration!(R)
# contour approximation
edit_boundary(R)

push!(LOAD_PATH,pwd()); include("Load_EditBoundary.jl");
R = read_region(); depuration!(R); edit_boundary(R);
=#