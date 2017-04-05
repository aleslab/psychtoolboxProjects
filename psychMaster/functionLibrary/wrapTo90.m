function [ angle ] = wrapTo90( angle )
%wrapTo90 This function wraps angles to [-90 90]
%
%  [angle] = wrapTo90(angle)
%  This function wraps angles to a 180 degree interval. This is used for
%  stimuli that are symmetric (i.e. gabors) that for example look the same
%  if they are rotated 45 degrees or 225 degrees
%

% 10/2015 - created by Justin Ales
%

%First wrap to 180;
angle = wrapTo180(angle);

%Now we can mirror flip any angles over 90 to lay in the [-90 90] range
% if angle>90
%     angle = angle-180;
% elseif angle<=-90
%     angle = angle+180;
% else
%     angle = angle;
% end

angle(angle>90)   = angle(angle>90)-180;
angle(angle<=-90) = angle(angle<=-90) + 180;
end

