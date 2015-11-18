function [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance, IOD)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% for when the eye and fixation point give a right-angle triangle.

% thetaPrime = atan ( objectX / (viewingDistance - objectZ));
% screenX = viewingDistance*tan(thetaPrime);
% screenY = objectY;

%% for when the eye and fixation point do not form a right-angle triangle
if objectX >= 0;
    halfId = IOD/2;
else
    halfId = (-IOD)/2;
end
%Half of the interocular distance -- the distance the eye
%should be from the fixation point. If we're moving to the left of the
%fixation point, the half IOD will be a negative value as the fixation
%point is 0 in x.
BC = sqrt((halfId^2)+(viewingDistance^2)); %distance between the fixation 
theta = 2*atan(objectX/(2*viewingDistance)); %initial visual angle
%point and the centre of the eye
angleX = asin(halfId/BC); %rearranged sine rule
angleZ = (pi/2) - angleX; % angles in a triangle
angleY = pi - theta - angleZ; %angles in a triangle
angleTau = (pi/2) - angleY; % tau = pi - pi/2 - angleY will simplify to this
AC = (objectX*sin(angleZ))/sin(theta); %the distance between the centre of 
%the eye and the objectX (A) starting point
lengthOmega = sqrt((objectZ^2)+(AC^2)- (2*objectZ*AC*cos(angleTau))); %cosine rule
angleBeta = asin((viewingDistance - objectZ)/lengthOmega); %rearranged sine rule
angleDelta = (pi/2) - angleBeta; %pi - pi/2 - angleBeta simplifies to this; angles in a triangle add up to pi rads
lengthAPrimeA = (objectZ*sin(angleDelta))/(sin(angleBeta)); %using sine rule to find A'A
screenX = objectX + lengthAPrimeA; %A'B = A'A + AB
screenY = objectY; % 0 for both




end

