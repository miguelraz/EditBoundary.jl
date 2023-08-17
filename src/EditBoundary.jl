module EditBoundary
#__precompile__(false)

#############################################
#  Julia Packages
#############################################
# Text input and output
import Printf: @sprintf
import DelimitedFiles: readdlm

# Interactivity using GLMakie
import GLMakie: Observable, Figure, Axis, DataAspect, Keyboard
import GLMakie: Menu, Label, events, on, lift, Slider, Button, Textbox
import GLMakie: hidespines!, lines!, reset_limits!, set_close_to!
import GeometryBasics.Point, GeometryBasics.Point2f
# To pick and open files
using NativeFileDialog
# Linear algebra
using LinearAlgebra: norm
# Optimization
using Optim

# load the main data structure
include("data_structures/DATA_UNAMALLA.jl")
export DataRegion
# load routines for our figure layout in GLMakie 
include("contour_creator/obs2xy.jl")
include("contour_creator/bnd_windict.jl")
# BND_WINDICT.jl
export region_window
# OBS2XY.jl
export bnd2obs, bnd2obsp

include("geometry/get_npts.jl")
include("geometry/area.jl")
include("geometry/folding.jl")
include("geometry/distseg.jl")
include("geometry/scaleinb2.jl")
include("geometry/triangle_areas.jl")
include("geometry/triangle_measures.jl")
include("geometry/fg_perimeter.jl")
include("geometry/reverse_orientation.jl")

# AREA.jl
export J₂, αk
# DELETE_REPTS
export del_repts!
# DISTSEG 
export distseg
# FG_PERIMETER
export gety, getxy, perim, ∂perim, fg!
# GET_NPTS 
export get_npts
# REVERSE_ORIENTATION
export reverse_orientation!
# FOLDING
export folding

include("io/get_name.jl")
include("io/get_path.jl")
include("io/regionio.jl")
include("io/copy_region.jl")
include("io/io_order.jl")

# GET_NAME
export get_name
# GET_PATH
export get_path_img, get_path_geo, get_path_region, get_dir
# REGIONIO
export readXYZ, readGEO, read_region, saveXYZ, save_region
export ask_save_region, save_new_region
# COPY_REGION
export copy_region
# GET_REGION
export get_region
# IO_ORDER
export read_order, save_order

include("edit_boundary/point_elimination.jl")
include("edit_boundary/min_perimeter.jl")
include("edit_boundary/auto_simplification.jl")
include("edit_boundary/edit_boundary.jl")

# POINT_ELIMINATION
# TODO - rename these asap
export remove!, areas, areasine, radiusine, carnot, del_pts, del_pts!, del_repts! 
# MIN_PERIMETER
export min_perimeter, min_perimeter!
# AUTO_SIMPLIFICATION
export auto_simp, auto_simp!
# EDIT_BOUNDARY
export edit_boundary

end
