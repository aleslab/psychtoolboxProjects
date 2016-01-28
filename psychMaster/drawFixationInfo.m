function [expInfo] = drawFixationInfo(expInfo)
%Information to draw boxes around the fixation crosses to indicate a participant can make
%a response

%x centre is expInfo.center(1)
%y centre is expInfo.center(2)
fixCrossDimPix = 20; %the size of the arms of our fixation cross
fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0]; %fixation cross x coordinates
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix]; %fixation cross y coordinates
expInfo.FixCoords = [fixXCoords; fixYCoords]; %combined fixation cross coordinates
expInfo.fixWidthPix = 1; %the line width of the fixation cross
expInfo.lw = 1;

%box surrounding fixation cross when you can make a response
leftPointX = expInfo.center(1) - 30;
rightPointX = expInfo.center(1) + 30;
PointY1 = expInfo.center(2) + 30;
PointY2 = expInfo.center(2) - 30;

boxXcoords = [leftPointX leftPointX rightPointX rightPointX leftPointX rightPointX leftPointX rightPointX];
boxYcoords = [PointY1 PointY2 PointY1 PointY2 PointY1 PointY1 PointY2 PointY2];
expInfo.boxCoords = [boxXcoords; boxYcoords];



