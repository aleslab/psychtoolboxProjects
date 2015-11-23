function [screen] = calculateScreenLocation(object, eye, fixation)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% for when the eye and fixation point give a right-angle triangle.

% thetaPrime = atan ( objectX / (viewingDistance - objectZ));
% screenX = viewingDistance*tan(thetaPrime);
% screenY = objectY;

%% for when the eye and fixation point do not form a right-angle triangle
% if objectX >= 0;
%     halfId = IOD/2;
% else
%     halfId = (-IOD)/2;
% end

% currently not using "eye" at all in this code, but will need to at some
% point.
screenZ = fixation(:,3); %viewing distance

%theta = atan(objectX/objectZ); %really needs to be atan2 but errors

theta = atan(object(:,1)/object(:,3));
screenX = screenZ * tan(theta); %again needs to be tan2
screenY = object(:,2);

screen = [screenX, screenY, screenZ];


end

