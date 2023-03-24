//region polygon_24-Mar-23-1454
//idreg 0
//nholes 0
//extbnd
//npts 3
Point(1) = {5.67307710647583,3.5,0,1};
Point(2) = {6.461538791656494,6.634615898132324,0,1};
Point(3) = {3.32692289352417,6.59615421295166,0,1};
//lines
Line(1) = {3,1};
Line(2) = {1,2};
Line(3) = {2,3};
//polygons
Line Loop(1) = {1:3};
Plane Surface(1) = {1};
