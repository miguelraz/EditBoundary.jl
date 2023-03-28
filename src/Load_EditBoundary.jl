#############################################
#  Julia Packages
#############################################
import Base.range
# Text input and output
import Printf: @sprintf
import DelimitedFiles: readdlm
import Base64: stringmime
import Dates: format, now
# Interactivity
import GLMakie: Node, Observable, Figure
import GeometryBasics.Point
# Pop up a window to select a file
import Gtk: GConstants, bytestring, destroy, GtkNullContainer, GtkFileChooserDialog
import Gtk: GtkFileChooser, GtkFileChooserAction, GtkFileFilter, GObject
# Linear algebra
using LinearAlgebra: norm
# Optimization
using Optim
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
include("IO/GET_REGION.jl")

include("contour_creator/OBS2XY.jl")
include("contour_creator/BND_WINDICT.jl")
include("contour_creator/ADD_HOLES.jl")
include("contour_creator/CONTOUR_CREATOR.jl")

#include("edit_boundary/POINT_ELIMINATION.jl")
include("edit_boundary/MIN_PERIMETER.jl")
include("edit_boundary/AUTO_SIMPLIFICATION.jl")
include("edit_boundary/REMOVE_HOLES.jl")
#include("edit_boundary/EDIT_BOUNDARY.jl")
#include("edit_boundary/GET_TOLERANCES_SLIDER_VALUES.")