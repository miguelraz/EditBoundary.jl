module EditBoundary
__precompile__(false)

# Write your package code here.

#############################################
#  Julia Packages
#############################################
# Text input and output
using Printf,
    DelimitedFiles,
    FileIO
using Base64: stringmime
using Dates: format, now
# Interactivity
using CairoMakie,
    GLMakie,
    Makie.GeometryBasics,
    Colors,
    WebIO,
    PlotlyJS
# Pop up a window to select a file
using Gtk
using IJulia: clear_output
# Linear algebra
using LinearAlgebra.BLAS: nrm2,
    dot,
    blascopy!,
    scal!
using LinearAlgebra: norm
# Optimization
using Optim


#############################################
# UNAMalla Packages
#############################################
#d = Sys.iswindows() ? "\\" : "/"

#dir = "data_structures"*d
#modules = ["DATA_UNAMALLA" ]
#include.(dir.*modules.*".jl")
include("data_structures/DATA_UNAMALLA.jl")
@info "kiubo"

#=
dir = "geometry"*d
modules = ["GET_NPTS"
           "AREA"
           "REFLEX"
           "ARCLENGTH"
           "GET_ANGLES"
           "FOLDING"
           "DISTSEG"
           "INPOLY"
           "SCALEINB2"
           "HULL"
           "POCKETS"
           "TRIANGLE_AREAS"
           "TRIANGLE_RADIUS"
           "REGION_INFO"
           "CHECK_HOLES"
           "FIND_SMALL_ANGLES"
           "FIND_SMALL_SECTIONS"
           "COLLAPSE_SMALL_GAPS"
           "FG_PERIMETER" ]
include.(dir.*modules.*".jl") 

dir = "IO"*d
modules = [ "GET_NAME"
            "GET_PATH"
            "REGIONIO"
            "DELETE_REPTS"
            "COPY_REGION"
            "DEPURATION"
            "GET_REGION"
            "IO_ORDER"]
include.(dir.*modules.*".jl")

dir = "contour_creator"*d
modules = [ "OBS2XY"
            "BND_WINDICT"
            "ADD_HOLES"
            "CONTOUR_CREATOR" ]
include.(dir.*modules.*".jl")


dir = "plot"*d
modules = [ "PLOT_LAYOUT"
            "PLOT_MEASURE"
            "PLOT_REGION"
            "MENUS"
            "REGION_TABLES"
            "MEASURE_TABLE"
            "SHOW_REGION_INFO"
            ]
include.(dir.*modules.*".jl")

dir = "edit_boundary"*d
modules = [     "POINT_ELIMINATION"
                "MIN_PERIMETER"
                "AUTO_SIMPLIFICATION"
                "REMOVE_HOLES"
                "EDIT_BOUNDARY" ]
include.(dir.*modules.*".jl")

=#

end
