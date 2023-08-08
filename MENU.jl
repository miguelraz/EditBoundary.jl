########### 
### META:
# open a file dialog to choose a XYZ file in the folder src/regions 
# and read the file into a julia struct
R = read_region()
# check polygon orientation
reverse_orientation!(R)
# delete repeated points
del_repts!(R)
# check for self-intersecions
folding(R)
# open interactive window in GLMakie
edit_boundary(R)