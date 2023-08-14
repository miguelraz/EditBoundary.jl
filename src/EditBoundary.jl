module EditBoundary

#############################################
#  Julia Packages
#############################################
import Base.range
# Text input and output
import Printf: @sprintf
import DelimitedFiles: readdlm
# Interactivity using GLMakie
# only load the necessary routines of GLMakie
import GLMakie: Observable, Figure, Axis, DataAspect, Keyboard
import GLMakie: Menu, Label, events, on, lift, Slider, Button, Textbox
import GLMakie: hidespines!, lines!, reset_limits!, set_close_to!
import GeometryBasics.Point, GeometryBasics.Point2f
# Pop up a window to select a file
# No more Gtk depedencies
# Now NativeFileDialog replaces Gtk for pick and save files
using NativeFileDialog
# Linear algebra
using LinearAlgebra: norm
# Optimization
using Optim

# load the main data structure
include("data_structures/DATA_UNAMALLA.jl")
export DataRegion
# load routines for our figure layout in GLMakie 
include("contour_creator/OBS2XY.jl")
include("contour_creator/BND_WINDICT.jl")
# BND_WINDICT.jl
export region_window
# OBS2XY.jl
export bnd2obs, bnd2obsp

#include("geometry/ARCLENGTH.jl")
include("geometry/GET_NPTS.jl")
include("geometry/AREA.jl")
include("geometry/FOLDING.jl")
include("geometry/DISTSEG.jl")
include("geometry/SCALEINB2.jl")
include("geometry/TRIANGLE_AREAS.jl")
include("geometry/TRIANGLE_MEASURES.jl")
include("geometry/REGION_INFO.jl")
#include("geometry/CHECK_HOLES.jl")
include("geometry/FG_PERIMETER.jl")
include("geometry/REVERSE_ORIENTATION.jl")
#include("geometry/INPOLY.jl")
#include("geometry/REFLEX.jl")

# ARCLENGTH.jl
#export lengths, arclength, perim, arclength
# AREA.jl
export J₂, α
# CHECK_HOLES
#export check_holes
# DELETE_REPTS
export del_repts!
# DISTSEG 
export distseg
# FG_PERIMETER
export gety, getxy, perim, ∂perim, fg!
# FIND_SMALL_ANGLES 
#export modn
# FOLDING 
export folding
# GET_ANGLES 
#export get_cos, get_angle
# GET_NPTS 
export get_npts
# REVERSE_ORIENTATION
export reverse_orientation!
# INPOLY 
#export is_left, inpoly
# POCKETS 
#export pockets
# REFLEX 
#export reflex
# REGION_INFO 
#export basic_region_info

include("IO/GET_NAME.jl")
include("IO/GET_PATH.jl")
include("IO/REGIONIO.jl")
# include("IO/DELETE_REPTS.jl")
include("IO/COPY_REGION.jl")
include("IO/GET_REGION.jl")
include("IO/IO_ORDER.jl")
#include("IO/REGION_INFO.jl")

# GET_NAME
export get_name
# GET_PATH
# Gtk_save_dialog, get_dirpath, get_path_red, get_path_msh, get_path mesh, get_path_cut were removed
export get_path_img, get_path_geo, get_path_region, get_dir
# REGIONIO - TODO
export readXYZ, readPOLY, readGEO, read_region, saveXYZ, save_region
export ask_save_region, save_new_region
# DELETE_REPTS
#export perm_repts, delete_repts
# COPY_REGION
export copy_region
# DEPURATION
#export depuration
# GET_REGION
export get_region
# IO_ORDER
export read_order, save_order

include("edit_boundary/POINT_ELIMINATION.jl")
include("edit_boundary/MIN_PERIMETER.jl")
include("edit_boundary/AUTO_SIMPLIFICATION.jl")
include("edit_boundary/REMOVE_HOLES.jl")
include("edit_boundary/EDIT_BOUNDARY.jl")
#include("edit_boundary/GET_TOLERANCES_SLIDER_VALUES.jl")
#include("edit_boundary/EDITPOLY.jl")

# POINT_ELIMINATION
# TODO - rename these asap
# use del_repts! from edit_boundary/POINT_ELIMINATION.jl instead of delete_repts from IO/DELETE_REPTS
export remove_holes!, remove!, areas, areasine, radiusine, carnot, del_pts, del_pts!, del_repts! 
# MIN_PERIMETER
export min_perimeter, min_perimeter!
# AUTO_SIMPLIFICATION
export auto_simp, auto_simp!
# REMOVE_HOLES
export remove_holes!
# EDIT_BOUNDARY
export edit_boundary
# GET_TOLERANCES_SLIDER_VALUES
export tol2per, get_tolerances_slider_values
# EDIT_POLY
# TODO - WTF IS THIS
#export edit_bnd3

end
