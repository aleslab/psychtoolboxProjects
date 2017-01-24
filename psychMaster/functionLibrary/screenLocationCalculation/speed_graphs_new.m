% code for generating graphs that represent what is really happening in my
% speed change intervals.

nt = 1000;
tend = 1;
samplesPerSecond = nt/tend;
dt = tend/nt;
T = linspace(0,tend-dt,nt);
i = 1;

eyeL = [-3, 0, 0];
eyeR = [3, 0, 0];
fixation = [0, 0, 97];
objectStart = [0, 0, 107];
deltaV=15; %change in velocity in speed change interval
objectVelocity = -20+ (1)*[deltaV*ones(nt/2,1) -deltaV*ones(nt/2,1)] ; %cm/s

objectCurrentPosition = objectStart;

for i = 1:nt
    pos = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    deltaZ = objectVelocity(i)*dt; %change in z axis position
     objectCurrentPosition(3) = objectCurrentPosition(3) + deltaZ;
     xpos(i) = pos(1); %x position of the line in x y coordinates converted from x y z
     xposVARad(i) = (atan(xpos(i)./97)); %theta = atan(screenPos/viewingdistance) in radians
     xposVAdeg(i) = rad2deg(xposVARad(i)); %convert to degrees
     xposVA(i) = xposVAdeg(i)*60; %*2 for 2 eyes, *60 into arcmin
     
end

vel=diff(xpos)/dt; %velocity is the slope of the distance time graph in cm/s -- differentiate to find
Accel=diff(vel)/dt; %acceleration is the slope of the velocity time graph in cm/s^2 -- differentiate to find

velVA = diff(xposVA)/dt; %velocity in visual angle
AccelVAwithCentre = diff(velVA)/dt; %acceleration in visual angle
AccelVA = AccelVAwithCentre;
AccelVA(500) = [];
%% plot the graphs of velocity, position and acceleration on the retina
figure(101); clf
plot(T(1:end-1),velVA, '-k');
xlabel('time (s)');
ylabel('velocity (arcmin/s)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

figure(102); clf
plot(T,xposVA, '-k');
xlabel('time (s)');
ylabel('position (arcmin)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

figure(103); clf
plot(T(1:end-3),AccelVA, '-k'); 
%the second set of numbers are going to be shifted ever so slightly because 
%I've removed the central acceleration point that is basically an error
xlabel('time (s)');
ylabel('acceleration (arcmin/s^2)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

