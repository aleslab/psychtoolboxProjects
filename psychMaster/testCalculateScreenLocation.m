%Tests for calculating screen location for object moving in depth

% %1
% %[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance)
% 
% %Input
% viewingDistance = 57;
% objectX = 0;
% objectY = 0;
% objectZ = 0;
% 
% %expected result
% expectedScreenX = 0;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(screenX==expectedScreenX,'Failure');
% assert(screenY==expectedScreenY,'Failure');
% 
% %2
% %Input
% viewingDistance = 57;
% objectX = 10;
% objectY = 0;
% objectZ = 0;
% 
% %expected result
% expectedScreenX = 10;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(screenX==expectedScreenX,'Failure');
% assert(screenY==expectedScreenY,'Failure');
% 
% %3
% %Input
% viewingDistance = 57;
% objectX = 10;
% objectY = 0;
% objectZ = 10;
% 
% %expected result
% expectedScreenX = 12.12765957;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(abs(screenX-expectedScreenX)<.001,'Failure');
% assert(abs(screenY-expectedScreenY)<.001,'Failure');
% 
% 
% %4
% 
% %Input
% viewingDistance = 57;
% objectX = 25;
% objectY = 0;
% objectZ = 25;
% 
% %expected result
% expectedScreenX = 44.53125;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(abs(screenX-expectedScreenX)<.01,'Failure');
% assert(abs(screenY-expectedScreenY)<.01,'Failure');
% 
% %5
% 
% %Input
% viewingDistance = 57;
% objectX = -10;
% objectY = 0;
% objectZ = 10;
% 
% %expected result
% expectedScreenX = -12.12765957;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(abs(screenX-expectedScreenX)<.001,'Failure');
% assert(abs(screenY-expectedScreenY)<.001,'Failure');
% 
% disp('It worked');
% 
% %6
% 
% %Input
% viewingDistance = 57;
% objectX = 10;
% objectY = 0;
% objectZ = -10;
% 
% %expected result
% expectedScreenX = 8.507;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance);
% 
% assert(abs(screenX-expectedScreenX)<.001,'Failure');
% assert(abs(screenY-expectedScreenY)<.001,'Failure');

%% for when the fixation point and centre of the eye do not produce a right angle

% %1
% %input
% viewingDistance = 57; %Vd
% objectX = 10; %AB
% objectY = 0; %ignore
% objectZ = 10; %d
% IOD = 6.3; %Interocular distance, Id
% 
% %expected result
% expectedScreenX = 11.36807813;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance, IOD); 
% %altered this so that it feeds into a function that does this when there
% %isn't a right angle.
% 
% assert(abs(screenX-expectedScreenX)<.01,'Failure');
% assert(abs(screenY-expectedScreenY)<.01,'Failure');
% disp('It worked');

%2
% this doesn't work... If the interocular distance were 0, you would expect
% the value to be the same as when we do the right angle triangle
% calculations... wouldn't you? But it isn't, it comes out as 11.6338 instead
% of 12.1277.

% viewingDistance = 57; %Vd
% objectX = 10; %AB
% objectY = 0; %ignore
% objectZ = 10; %d
% IOD = 0; %Interocular distance, Id
% 
% %expected result
% expectedScreenX = 12.12765957;
% expectedScreenY = 0;
% [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance, IOD); 
% %altered this so that it feeds into a function that does this when there
% %isn't a right angle.
% 
% assert(abs(screenX-expectedScreenX)<.01,'Failure');
% assert(abs(screenY-expectedScreenY)<.01,'Failure');
% disp('It worked');

%3 
%When A is between B and C in the X axis

% viewingDistance = 57; %Vd
% objectX = -2; %AB
% objectY = 0; %ignore
% objectZ = 10; %d
% IOD = 6.3; %Interocular distance, Id

%gets to the stage of calculating angleBeta but then asin(47/46.93264125)
%(asin(vd-d/angleOmega)) is bigger than 1, which is impossible, so a math error
%is returned. So this method of working screenX (A'B) out doesn't work for 
%this scenario.

%But would you ever want this scenario? Because in theory, to move towards
%the observer when the starting point is between the point at the centre 
%of the eye and the fixation point, wouldn't the line generated on the
%screen need to fairly spontaneously change direction -- which might cause
%problems? 

%Would we therefore want to make the code so that there is always at least
%the interocular distance between the lines on the screen?

%% non right angle with correct method for finding screenX with one eye

%with the centre of the eye as (0,0,0) and +x towards the right, +y upwards and +z is towards the front. 
IOD = 6;
viewingDistance = 57;
eyeX = 0;
eyeY = 0;
eyeZ = 0;
objectX = 10;
objectY = 0;
objectZ = 40;
fixationX = -3;
fixationY = 0;
fixationZ = viewingDistance;
expectedScreenX = 14.25;
expectedScreenY = 0;

[screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance, IOD); 
%altered this so that it feeds into a function that does the calculation  
%when there isn't a right angle.

%Really want to make this so that it reads in object(x,y,z); fixation
%(x,y,z); fixation(x,y,z), the viewing distance and IOD.

assert(abs(screenX-expectedScreenX)<.1,'Failure');
assert(abs(screenY-expectedScreenY)<.1,'Failure');
disp('It worked');
