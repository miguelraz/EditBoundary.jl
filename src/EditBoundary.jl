module EditBoundary

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
using LinearAlgebra: norm
using Optim

# Data Structures
include("data_structures/dataregion.jl")
export DataRegion

# Contour Creator - figure layout in GLMakie 
include("contour_creator/obs2xy.jl")
export bnd2obs, bnd2obsp
include("contour_creator/bnd_windict.jl")
export region_window

# Geometry
include("geometry/area.jl")
export J₂, αk
include("geometry/get_npts.jl")
export get_npts
include("geometry/folding.jl")
export folding
include("geometry/distseg.jl")
export distseg
include("geometry/triangle_measures.jl") # used by RadiusSine and AreaSine
include("geometry/fg_perimeter.jl")
export gety, getxy, perim, ∂perim, fg!
include("geometry/reverse_orientation.jl")
export reverse_orientation!

# IO
include("io/get_path.jl")
export get_path_region
include("io/regionio.jl")
export readXYZ, readGEO, read_region, saveXYZ, save_region
export ask_save_region, save_new_region
include("io/copy_region.jl")
export copy_region
include("io/io_order.jl")
export read_order, save_order

# Edit Boundary
include("edit_boundary/point_elimination.jl")
export remove!, areas, areasine, radiusine, carnot, del_pts, del_pts!, del_repts! 
include("edit_boundary/min_perimeter.jl")
export min_perimeter, min_perimeter!
include("edit_boundary/auto_simplification.jl")
export auto_simp, auto_simp!
include("edit_boundary/edit_boundary.jl")
export edit_boundary

end