function [ LEVel, REVel ] = retinalVelocity( loc, vel )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Define the location of the eyes
LE = [-3,0];
RE = [ 3,0];

%The vector from the location in the world to the eyes
a = LE-loc;
b = RE-loc;

%The angles between the velocity and the direction to the eye
alpha = acosd( dot( a, vel) / (norm(a)* norm(vel) ));
beta  = acosd( dot( b, vel) / (norm(b)* norm(vel) ));

%THis is a funny thing.  The dot product above just gives us the
%magnitude of the angle, this gives us the sign
leSign = sign(a(1)*vel(2) - a(2)*vel(1));
reSign = sign(b(1)*vel(2) - b(2)*vel(1));

%Now lets put it al together and calculate the component of the velocity
%visible on the retina.
LEVel = leSign*atand( norm(vel) * sind(alpha)/ norm(a));
REVel = reSign*atand( norm(vel) * sind(beta)/ norm(b));


end

