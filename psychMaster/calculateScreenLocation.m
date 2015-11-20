function [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance, IOD)
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
screenZ = viewingDistance;

theta = atan(objectX/objectZ); %really needs to be atan2 but errors
screenX = screenZ * tan(theta); %again needs to be tan2
screenY = objectY;




end

