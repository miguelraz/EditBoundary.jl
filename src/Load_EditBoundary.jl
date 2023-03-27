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

# ARCLENGTH.jl
export lengths, arclength, perimeter, arclength
# AREA.jl
export J₂, α, cell_index_bnd, infoα
# CHECK_HOLES
export check_holes
# COLLAPSE_SMALL_GAPS
export collapse_small_gaps
# DISTSEG 
export distseg
# FG_PERIMETER
export gety, getxy, perim, ∂perim, fg! 
# FIND_SMALL_ANGLES 
export modn, find_small_angles
# FIND_SMALL_ANGLES
export find_small_sections 
# FOLDING 
export seg_intersect!, folding
# GET_ANGLES 
export get_cos, get_angle
# GET_NPTS 
export get_npts
# HULL 
export getx, gety, orientation, convex_hull
# INPOLY 
export is_left, inpoly
# POCKETS 
export idpockets, pockets
# REFLEX 
export reflex
# REGION_INFO 
export basic_region_info

include("IO/GET_NAME.jl")
include("IO/GET_PATH.jl")
include("IO/REGIONIO.jl")
include("IO/DELETE_REPTS.jl")
include("IO/COPY_REGION.jl")
include("IO/DEPURATION.jl")
include("IO/GET_REGION.jl")
include("IO/IO_ORDER.jl")

# GET_NAME
export get_name
# GET_PATH
export Gtk_save_dialog, get_path, get_dir, get_path_cut, get_path_img, get_path_red
export get_path_msh, get_path_mesh, get_path_geo, get_path_region, get_path_figures
export get_dirfiles
# REGIONIO - TODO
export readXYZ, readPOLY, readGEO, read_region, path_poly, saveXYZ, save_region
export ask_save_region, save_new_region
# DELETE_REPTS
export perm_repts, delete_repts
# COPY_REGION
export copy_region
# DEPURATION
export depuration
# GET_REGION
export get_region
# IO_ORDER
export read_order, save_order

include("contour_creator/OBS2XY.jl")
include("contour_creator/BND_WINDICT.jl")
include("contour_creator/ADD_HOLES.jl")
include("contour_creator/CONTOUR_CREATOR.jl")

# OBS2XY
# TODO - perf - use tuples?
export VecPts, p2f, p2f1, p2fp, bnd2obs, bnd2obs1, bnd2obsp, obs2bnd, obs2xy, obs2xy
# BND_WINDICT
export bnd_window, region_window, bnd_dict
# ADD_HOLES
export get_centroid, add_hole
# CONTOUR_CREATOR
export contour_creator, contour_creator_menu

include("plot/PLOT_LAYOUT.jl")
include("plot/PLOT_MEASURE.jl")
include("plot/PLOT_REGION.jl")
include("plot/MENUS.jl")
include("plot/REGION_TABLES.jl")
include("plot/MEASURE_TABLE.jl")
include("plot/SHOW_REGION_INFO.jl")
include("plot/THEREHOLD_TABLE.jl")
include("plot/PLOT_SIMP_PER.jl")

# PLOT_LAYOUT
export Daxis, DicLay, menu_layout, showviz, bmesh_layout, region_colors_RGB, region_colors
# PLOT_MEASURE
export plot_measure
# PLOT_REGION
export C, get4bnd, draw_corners, draw_bndsides, fill_region, plot_region, plot_region_holes, plot_region_cuts
export plot_region, update_plot_regions!, update_tab_regions!, update_plot_region!, save_region_plot
# MENUS
export 
# REGION_TABLES
export 
# MEASURE_TABLE
export measure_table, region_table, menu_trace, draw_menu
# SHOW_REGION_INFO
export show_region_info
# THEREHOLD_TABLE
export plot_therehold_table
# PLOT_SIMP_PER
export plot_simp_per

include("edit_boundary/POINT_ELIMINATION.jl")
include("edit_boundary/MIN_PERIMETER.jl")
include("edit_boundary/AUTO_SIMPLIFICATION.jl")
include("edit_boundary/REMOVE_HOLES.jl")
include("edit_boundary/EDIT_BOUNDARY.jl")
include("edit_boundary/GET_TOLERANCES_SLIDER_VALUES.jl")
include("edit_boundary/EDITPOLY.jl")

# POINT_ELIMINATION
# TODO - rename these asap
export remove_holes!, remove!, areas, areasine, radiusine, carnot, del_pts, del_pts!
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
export edit_bnd3