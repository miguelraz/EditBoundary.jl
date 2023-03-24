//region polygon_24-Mar-23-1349
//idreg 0
//nholes 2
//extbnd
//npts 1
Point(1) = {3.365384578704834,5.90384578704834,0,1};
//hole 1
//npts 1
Point(2) = {3.384615421295166,3.461538553237915,0,1};
//hole 2
//npts 2
Point(3) = {5.634615421295166,3.403846025466919,0,1};
Point(4) = {5.653846263885498,6.0,0,1};
//lines
Line(1) = {1,1};
Line(2) = {2,2};
Line(3) = {4,3};
Line(4) = {3,4};
//polygons
Line Loop(1) = {1:1};
Plane Surface(1) = {1};
Line Loop(2) = {2:2};
Plane Surface(2) = {2};
Line Loop(3) = {3:4};
Plane Surface(3) = {3};
