push!(LOAD_PATH, pwd());
include("Load_EditBoundary.jl");

@time contour_creator_menu();

"""
edit_boundary(R₀)
"""
edit_boundary(R0)

########### 
### META:
using EditBoundary
R = read_region()
reverse_orientation!(R)
del_repts!(R)
folding(R)
edit_boundary(R)