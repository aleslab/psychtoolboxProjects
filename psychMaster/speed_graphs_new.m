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
objectStart = [-5, 0, 97];
deltaV=6; %change in velocity in speed change interval
objectVelocity = 8+ (1)*[deltaV*ones(nt/2,1) -deltaV*ones(nt/2,1)] ; %cm/s

objectCurrentPosition = objectStart;

for i = 1:nt
    posL = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    deltaZ = objectVelocity(i)*dt; %change in z axis position
     objectCurrentPosition(1) = objectCurrentPosition(1) + deltaZ;
     xposL(i) = posL(1); %x position of the line in x y coordinates converted from x y z
     xposVARadL(i) = (atan(xposL(i)./97)); %theta = atan(screenPos/viewingdistance) in radians
     xposVAdegL(i) = rad2deg(xposVARadL(i)); %convert to degrees
     xposVAL(i) = xposVAdegL(i)*60; %*2 for 2 eyes, *60 into arcmin
     
end

vel=diff(xposL)/dt; %velocity is the slope of the distance time graph in cm/s -- differentiate to find
Accel=diff(vel)/dt; %acceleration is the slope of the velocity time graph in cm/s^2 -- differentiate to find

velVAL = diff(xposVAL)/dt; %velocity in visual angle
AccelVAwithCentreL = diff(velVAL)/dt; %acceleration in visual angle
AccelVAL = AccelVAwithCentreL;
AccelVAL(500) = [];
Accel1stInterval = AccelVAL([1 499]);
Accel2ndInterval = AccelVAL([500 997]);
%% plot the graphs of velocity, position and acceleration on the retina
figure(101); hold on 
plot(T(1:end-1),velVAL, '-k');
xlabel('time (s)');
ylabel('velocity (arcmin/s)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

figure(102); hold on
plot(T,xposVAL, '-k');
xlabel('time (s)');
ylabel('position (arcmin)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

figure(103); hold on
plot(T(1:end-3),AccelVAL, '-k'); 
%the second set of numbers are going to be shifted ever so slightly because 
%I've removed the central acceleration point that is basically an error
xlabel('time (s)');
ylabel('acceleration (arcmin/s^2)');
set(gca, 'Xtick', 0:0.1:1);
set(gca, 'FontSize',18);

