function [screenX,screenY] = calculateScreenLocation(objectX,objectY,objectZ,viewingDistance)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


thetaPrime = atan ( objectX / (viewingDistance - objectZ));
screenX = viewingDistance*tan(thetaPrime);
screenY = objectY;

end

