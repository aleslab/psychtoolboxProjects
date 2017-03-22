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


%Wrap to +/- 180 to  
a = wrapTo180(a);

b = wrapTo180(b);




%This is where I figure out the minimum angle .
%I do this by chaining some trigonometry operations together.
%First take the raw difference between the angles. 
%Convert this difference into the vector form using sin and cos
%than return convert back to an angle using the 4 quadrant inverse tangent.
%Example: this makes any difference over 180 degrees return the equivalent
%difference that's under 180.
D=a-b;
bFlip = b-180;

delta = atan2d(sind(D),cosd(D));

%Now check what the angle difference is going the other way around the
%clock. This is the critical step that mirror reverses 
dFlip = a-bFlip;
deltaFlip = atan2d(sind(dFlip),cosd(dFlip));

%deltaOther = 180-abs(delta);
% 
% if abs(delta)>abs(deltaFlip)
%     delta = deltaFlip;
% end

%The if above only works for scalar inputs
%This fixes the function to work for vector inputs
flipIdx = abs(delta)>abs(deltaFlip);
delta(flipIdx) = deltaFlip(flipIdx);

%delta = min(abs(delta),abs(deltaFlip));

%Make sure we're 0-180.
%a = mod(a,180);
%b = mod(b,180);



end



    


