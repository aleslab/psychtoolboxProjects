%Tests for calculating screen location for object moving in depth

%1
%[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance)

%Input
viewingDistance = 57;
objectX = 0;
objectY = 0;
objectZ = 0;

%expected result
expectedScreenX = 0;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(screenX==expectedScreenX,'Failure');
assert(screenY==expectedScreenY,'Failure');

%2
%Input
viewingDistance = 57;
objectX = 10;
objectY = 0;
objectZ = 0;

%expected result
expectedScreenX = 10;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(screenX==expectedScreenX,'Failure');
assert(screenY==expectedScreenY,'Failure');

%3
%Input
viewingDistance = 57;
objectX = 10;
objectY = 0;
objectZ = 10;

%expected result
expectedScreenX = 12.12765957;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(abs(screenX-expectedScreenX)<.001,'Failure');
assert(abs(screenY-expectedScreenY)<.001,'Failure');


%4

%Input
viewingDistance = 57;
objectX = 25;
objectY = 0;
objectZ = 25;

%expected result
expectedScreenX = 44.53125;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(abs(screenX-expectedScreenX)<.01,'Failure');
assert(abs(screenY-expectedScreenY)<.01,'Failure');

%5

%Input
viewingDistance = 57;
objectX = -10;
objectY = 0;
objectZ = 10;

%expected result
expectedScreenX = -12.12765957;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(abs(screenX-expectedScreenX)<.001,'Failure');
assert(abs(screenY-expectedScreenY)<.001,'Failure');

disp('It worked');

%6

%Input
viewingDistance = 57;
objectX = 10;
objectY = 0;
objectZ = -10;

%expected result
expectedScreenX = 8.507;
expectedScreenY = 0;
[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);

assert(abs(screenX-expectedScreenX)<.001,'Failure');
assert(abs(screenY-expectedScreenY)<.001,'Failure');