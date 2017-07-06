function [screen] = calculateHorizontalScreenLocation(fixation, object)

screenZ = fixation(3); %viewing distance; 57
theta = atan2(object(2),object(3));
screenY = screenZ * tan(theta); 
screenX = object(1);
screen = [screenX, screenY, screenZ];

end