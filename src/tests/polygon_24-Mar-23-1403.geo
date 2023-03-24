//region polygon_24-Mar-23-1403
//idreg 0
//nholes 0
//extbnd
//npts 3
Point(1) = {4.230769157409668,2.32692289352417,0,1};
Point(2) = {7.442307472229004,4.423076629638672,0,1};
Point(3) = {4.865384578704834,5.538461685180664,0,1};
//lines
Line(1) = {3,1};
Line(2) = {1,2};
Line(3) = {2,3};
//polygons
Line Loop(1) = {1:3};
Plane Surface(1) = {1};
