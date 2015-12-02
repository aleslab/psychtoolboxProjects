function [screenL, screenR] = calculateScreenLocation(fixation, object, eyeL, eyeR)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% for when the eye and fixation point give a right-angle triangle.

% thetaPrime = atan ( objectX / (viewingDistance - objectZ));
% screenX = viewingDistance*tan(thetaPrime);
% screenY = objectY;

%% for when the eye and fixation point do not form a right-angle triangle


%right now, the positions you get are always 3cm away from what you want on
%the screen -- 3cm to the left for the right eye and 3cm to the right for
%the left eye. So something to do with when and how we consider the 
%position of the two eyes.

%If you change this so that objectL/R = object + eye, the values you get
%are even more wrong -- they're six cm away from where they should be and 3
%cm from the line of the other eye. -- so this isn't it.

%But you do need to consider the position of the eyes in this at some point
%or you won't get a different result for each eye......

objectL = object - eyeL;
objectR = object - eyeR;

% objectL = object;
% objectR = object;


%left eye
screenLZ = fixation(3); %viewing distance; 57

%theta = atan(objectL(:,1)/objectL(:,3));
theta = atan2(objectL(1),objectL(3));
screenLX = screenLZ * tan(theta); 
screenLY = object(2);
screenL = [screenLX, screenLY, screenLZ] + eyeL;
%screenL = unadjustedscreenL - eyeL;


% screenZ = fixation(3);
% theta = atan2(object(1),object(3));
% screenX = screenZ * tan(theta); 
% screenY = object(2);
% 
% unadjustedScreenL = [screenX, screenY, screenZ];
% 
% screenL = unadjustedScreenL - eyeL;



%right eye
screenRZ = fixation(3); %viewing distance; 57

%theta = atan(object(:,1)/object(:,3));
theta = atan2(objectR(1),objectR(3));
screenRX = screenRZ * tan(theta); 
screenRY = objectR(2);
screenR = [screenRX, screenRY, screenRZ] + eyeR;
%screenR = unadjustedscreenR - eyeR;



% screenZ = fixation(3);
% theta = atan2(object(1),object(3));
% screenX = screenZ * tan(theta); 
% screenY = object(2);
% 
% unadjustedScreenR = [screenX, screenY, screenZ];
% 
% screenR = unadjustedScreenR - eyeR;

end


