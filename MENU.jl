########### 
### META:
# open a file dialog to choose a XYZ file in the folder src/regions 
# and read the file into a julia struct
using EditBoundary
@info "read_region"
@time R = read_region("./src/regions/mexico_water_bodies/Presa La Amistad.xyz")
#R = EditBoundary.read_demo()
# check polygon orientation
@info "reverse_orientation"
@time reverse_orientation!(R)
# delete repeated points
@info "del_repts"
@time del_repts!(R)
# check for self-intersecions
@info "folding"
@time folding(R)
# open interactive window in GLMakie
@info "edit_boundary"
@time edit_boundary(R)
using Profile
@profview edit_boundary(R)