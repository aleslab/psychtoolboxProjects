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
objectStart = [0, 0, 117];
deltaV=0; %change in velocity in speed change interval
objectVelocity = -40+ (1)*[deltaV*ones(nt/2,1) -deltaV*ones(nt/2,1)] ; %cm/s


% deltaV=0; %change in velocity in speed change interval %0.257 is approx threshold for fast, 1.12 is approx max for fast
% objectVelocity = 1.343 - (1)*[deltaV*ones(nt/2,1) -deltaV*ones(nt/2,1)] ; %cm/s
%For 0.3: deltaV = .237, objet Velocity = 1.343;

objectCurrentPosition = objectStart;

for i = 1:nt
    [LEpos REpos] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
     
     xpos(i) = LEpos(1); %x position of the line in x y coordinates converted from x y z
     xposRE(i) = REpos(1);
     xposVARad(i) = (atan(xpos(i)./97)); %theta = atan(screenPos/viewingdistance) in radians
     xposVAdeg(i) = rad2deg(xposVARad(i)); %convert to degrees
     
     xposVAdegRE(i) = atan(-1*LEpos(1)./97)*180/pi;
     
     xposVA(i) = xposVAdeg(i)*60; %*2 for 2 eyes, *60 into arcmin
     
     [ worldPos ] = getWorldPos( atand(97/3)- xposVAdeg(i), atand(97/3)+  xposVAdegRE(i) );
     
     posZ(i) = worldPos(2); % (2) is z (1) is x; 2D with z and x
     %jmaVelX(i) = retinalVelocity([objectCurrentPosition(1) objectCurrentPosition(3)],[objectVelocity(i),0]);
     %jmaVelZ(i) = retinalVelocity([objectCurrentPosition(1) objectCurrentPosition(3)],[0,objectVelocity(i)]);
     
     objectPos(:,i) = objectCurrentPosition;
     
     deltaZ = objectVelocity(i)*dt; %change in z axis position
     objectCurrentPosition(3) = objectCurrentPosition(3) + deltaZ; %(1) for crs (3) for accel
    
end

%jmaVel = 60*(jmaVel); %Convert to arcmin;
vel=diff(xpos)/dt; %velocity is the slope of the distance time graph in cm/s -- differentiate to find
Accel=diff(vel)/dt; %acceleration is the slope of the velocity time graph in cm/s^2 -- differentiate to find

velVA = diff(xposVA)/dt; %velocity in visual angle
AccelVAwithCentre = diff(velVA)/dt; %acceleration in visual angle
AccelVA = AccelVAwithCentre;
AccelVA(500) = [];
%% plot the graphs of velocity, position and acceleration on the retina
figure(101); hold on
plot(T(1:end-1),velVA);
xlabel('time (s)');
ylabel('velocity (arcmin/s)');
set(gca, 'Xtick', 0:0.2:1);

%plot(T,jmaVel, '-r');

% figure(102); clf
% plot(T,xposVA, '-k');
% xlabel('time (s)');
% ylabel('position (arcmin)');
% set(gca, 'Xtick', 0:0.1:1);
% set(gca, 'FontSize',18);
% 
% figure(103); clf
% plot(T(1:end-3),AccelVA, '-k'); 
% %the second set of numbers are going to be shifted ever so slightly because 
% %I've removed the central acceleration point that is basically an error
% xlabel('time (s)');
% ylabel('acceleration (arcmin/s^2)');
% set(gca, 'Xtick', 0:0.1:1);
% set(gca, 'FontSize',18);
% 
% 
% figure(104); hold on
% plot(T,posZ)

figure(105); hold on
plot(T(1:end-1),abs(diff(posZ)/dt))
xlabel('time (s)');
ylabel('velocity (cm/s)');

