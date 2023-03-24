//region polygon_24-Mar-23-1450
//idreg 0
//nholes 5
//extbnd
//npts 3
Point(1) = {1.82692289352417,3.442307710647583,0,1};
Point(2) = {6.019230365753174,0.865384578704834,0,1};
Point(3) = {8.40384578704834,0.865384578704834,0,1};
//hole 1
//npts 1
Point(4) = {7.0,0.11538457870483398,0,1};
//hole 2
//npts 1
Point(5) = {7.384615421295166,0.34615421295166016,0,1};
//hole 3
//npts 1
Point(6) = {7.961538314819336,0.365384578704834,0,1};
//hole 4
//npts 1
Point(7) = {7.711538791656494,0.865384578704834,0,1};
//hole 5
//npts 1
Point(8) = {5.826923370361328,0.48076915740966797,0,1};
//lines
Line(1) = {3,1};
Line(2) = {1,2};
Line(3) = {2,3};
Line(4) = {4,4};
Line(5) = {5,5};
Line(6) = {6,6};
Line(7) = {7,7};
Line(8) = {8,8};
//polygons
Line Loop(1) = {1:3};
Plane Surface(1) = {1};
Line Loop(2) = {4:4};
Plane Surface(2) = {2};
Line Loop(3) = {5:5};
Plane Surface(3) = {3};
Line Loop(4) = {6:6};
Plane Surface(4) = {4};
Line Loop(5) = {7:7};
Plane Surface(5) = {5};
Line Loop(6) = {8:8};
Plane Surface(6) = {6};
