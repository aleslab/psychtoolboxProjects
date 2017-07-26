% code for generating graphs that represent what is really happening in my
% speed change intervals.

nt = 1000;
tend = 0.482; %duration in seconds. as in t-end.
samplesPerSecond = nt/tend;
dt = tend/nt;
T = linspace(0,tend-dt,nt);
i = 1;

%all specified in [x y z] vectors
eyeL = [-3, 0, 0];
eyeR = [3, 0, 0];
fixation = [0, 0, 97]; 
objectStart = [0, 1, 97];

objectVelocity = -20*ones(nt,1); % velocity in cm/s

objectCurrentPosition = objectStart;

for i = 1:nt
    pos = calculateHorizontalScreenLocation(fixation, objectCurrentPosition);
    deltaZ = objectVelocity(i)*dt; %change in z axis position
     objectCurrentPosition(3) = objectCurrentPosition(3) + deltaZ;
     ypos(i) = pos(2); %x position of the line in x y coordinates converted from x y z
     yposVARad(i) = (atan(ypos(i)./97)); %theta = atan(screenPos/viewingdistance) in radians
     yposVAdeg(i) = rad2deg(yposVARad(i)); %convert to degrees
     yposVA(i) = yposVAdeg(i)*60; %*2 for 2 eyes, *60 into arcmin
     
end

vel=diff(ypos)/dt; %velocity is the slope of the distance time graph in cm/s -- differentiate to find
Accel=diff(vel)/dt; %acceleration is the slope of the velocity time graph in cm/s^2 -- differentiate to find

velVA = diff(yposVA)/dt; %velocity in visual angle
AccelVAwithCentre = diff(velVA)/dt; %acceleration in visual angle
AccelVA = AccelVAwithCentre;
AccelVA(500) = [];


loomVelVA = velVA.*2; %x2 because I want the speed of the entire size change, not just of the individual line
loomPosVA = yposVA.*2; % the size change of the entire stimulus can be worked out with this
loomAccelVA = AccelVA.*2;
loomDistVA = loomPosVA(1000) - loomPosVA(1); %distance travelled by the stimulus in arcmin/s

disp(loomVelVA(1)); %start speed in arcmin; 
disp(loomVelVA(999)); %end speed in arcmin
disp(loomDistVA);
%% plot the graphs of velocity, position and acceleration on the retina
% figure(101); clf
% plot(T(1:end-1),velVA, '-k');
% xlabel('time (s)');
% ylabel('velocity (arcmin/s)');
% set(gca, 'Xtick', 0:0.1:1);
% set(gca, 'FontSize',18);
% 
% figure(102); clf
% plot(T,yposVA, '-k');
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

