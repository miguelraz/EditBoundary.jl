########### 
### META:
# open a file dialog to choose a XYZ file in the folder src/regions 
# and read the file into a julia struct
using EditBoundary
R = read_region("./src/regions/mexico_water_bodies/Presa La Amistad.xyz")
#R = EditBoundary.read_demo()
# check polygon orientation
reverse_orientation!(R)
# delete repeated points
del_repts!(R)
# check for self-intersecions
folding(R)
# open interactive window in GLMakie
@time edit_boundary(R)
