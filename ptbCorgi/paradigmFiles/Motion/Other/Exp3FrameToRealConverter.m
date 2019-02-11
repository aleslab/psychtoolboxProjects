%horrible maths calculations for stuff I keep having to look up and check
%for experiment 3 speed discrimination with fixed distance. 
%what speeds and distances are actually travelled?

ifi = 0.0118; %frame length

velocitiesSec = [40 45 50 55 60 65 70 40]; %velocities used in these conditions in cm/s

velocitiesFrames = velocitiesSec * ifi;

nFrames = [61 54 49 44 41 37 35 91]; %frames in levels 1-7 and then the catch.

DistancesCm = velocitiesFrames .* nFrames;

meanDistance = mean(DistancesCm(1:7));

times = nFrames .* ifi;

pixPerCm = 36.9675;
pixPerDeg = 63.2439;

meanDistancePix = meanDistance * pixPerCm;
meanDistanceDeg = meanDistancePix / pixPerDeg;

%in fixed duration, 43 frames.

fixedDurTime = 43 * ifi;




