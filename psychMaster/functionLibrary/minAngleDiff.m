function [ delta ] = minAngleDiff(a,b )
%minAngleDiff This functions calculates the difference between angles
%
%   [ delta ] = minAngleDiff(a,b )
%    This function calculates a very particular difference between angles
%    Angles are circular and can cause problems when trying to find 
%    difference between angles.  For example: 90 and 460 and -270 all are
%    exactly the same angle. If you don't respect this you will get
%    erroneous difference values.  Additionaly, you can calculate
%    differences either clockwise or counterclockwise.  For example if you
%    have the two angles: -45 and  45.  The difference is either 90 degrees
%    or 270 degrees depending on which way around you go. 
%    Finaly, for our current purposes we are using symmetric stimuli so say
%    45 degrees is the same as 225 degrees.  We want to take this into
%    account as well.

%% 10/2016 - created by Justin Ales
%

When comparing angles it is easy to Detailed explanation goes here


% ax = cosd(a);
% ay = sind(a);
% 
% bx = cosd(b);
% by = sind(b);
% 
% 

%Wrap to +/- 180 to  
a = wrapTo180(a);

b = wrapTo180(b);




%This is where I figure out the minimum angle .
%I do this by chaining some trigonometry operations together.
D=a-b;
bFlip = b-180;

delta = atan2d(sind(D),cosd(D));

dFlip = a-bFlip;
deltaFlip = atan2d(sind(dFlip),cosd(dFlip));

%deltaOther = 180-abs(delta);
% 
if abs(delta)>abs(deltaFlip)
    delta = deltaFlip;
end

%delta = min(abs(delta),abs(deltaFlip));

%Make sure we're 0-180.
%a = mod(a,180);
%b = mod(b,180);



end



    


end

