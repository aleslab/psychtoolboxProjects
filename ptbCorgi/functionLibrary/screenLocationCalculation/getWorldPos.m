function [ pos ] = getWorldPos( LEangle, REangle )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Define the location of the eyes
%This is the origin of our two lines
LE = [-3,0];
RE = [ 3,0];

%For the second point we're going to move one unit towards nose
%Assuming always convergent.
LE2(1) = -2;
LE2(2) = 1*tand(LEangle);
RE2(1) = 2;
RE2(2) = 1*tand(REangle);

%Yuck, this is so easy to get wrong.
x1 = RE2(1);
y1 = RE2(2);
x2 = RE(1);
y2 = RE(2);
x3 = LE(1);
y3 = LE(2);
x4 = LE2(1);
y4 = LE2(2);

numx  = (x1*y2 - y1*x2)*(x3-x4) - (x1 - x2)*(x3*y4-y3*x4);
numy  = (x1*y2 - y1*x2)*(y3-y4) - (y1 - y2)*(x3*y4-y3*x4);

denom = (x1 - x2)*(y3-y4) - (y1 - y2)*(x3-x4);

pos(1) = numx/denom;
pos(2) = numy/denom;
end

