
%% calculateScreenLocation other important inputs
eyeL = [-3,0,0]; %left eye position
eyeR = [3,0,0]; %right eye position
fixation = [0,0,97]; %viewing distance
depthStart = fixation + [0, 0, 20]; %the start position of the lines in depth
depthEnd = fixation + [0, 0, -20]; %the end position of the lines in depth
% depthStart = fixation + [0, 0, 10]; %the start position of the lines in depth
% depthEnd = fixation + [0, 0, -10];


totalDistances = repmat(40,1,7); %the total distance travelled in an interval
%totalDistances = repmat(20,1,7);
section1distances = [20 17.5 15 12.5 10 7.5 5];
%section1distances = [20 22.5 25 27.5 30 32.5 35]; %the distance travelled in section 1 of an interval
%section1distances = [10 11.25 12.5 13.75 15 16.25 17.5];
section2distances = totalDistances - section1distances; %the distance travelled in section 2 of an interval
levelChanges = struct();

%% Screen locations in degrees for an object moving in depth

[screenLstart, screenRstart] = calculateScreenLocation(fixation, depthStart, eyeL, eyeR);
%calculates the start position on each screen half in cm for the object in depth
%to be in that position

[screenLend, screenRend] = calculateScreenLocation(fixation, depthEnd, eyeL, eyeR);
% calculates the end position of the lines on each screen half

for i = 1:length(totalDistances);
    
    changePos = depthStart - [0, 0, section1distances(i)]; %position the speed change occurs at in x y z
    
    [screenLchange, screenRchange] = calculateScreenLocation(fixation, changePos, eyeL, eyeR); 
    %position change occurs at on the screen
    
    levelChanges.depthChange(i) = changePos(3); %the z coordinate at the point of the speed change
    
    levelChanges.screenLChangePos(i) = screenLchange(1);
    levelChanges.screenRChangePos(i) = screenRchange(1);
    
end

%finding the start position in visual angle
depthStartrad = atan(screenRstart(1)/97);
depthStartdeg = rad2deg(depthStartrad);
depthStartVA = depthStartdeg*60;

levelChanges.startAngle = depthStartVA;

%finding the end position in visual angle
depthEndrad = atan(screenRend(1)/97);
depthEnddeg = rad2deg(depthEndrad);
depthEndVA = depthEnddeg*60;

levelChanges.endAngle = depthEndVA;

%finding the position of the speed change in visual angle
for i = 1:length(levelChanges.depthChange);
    
    change = [levelChanges.screenRChangePos(i)];
    depthChangerad = atan(change/97);
    depthChangedeg = rad2deg(depthChangerad);
    depthChangeVA = depthChangedeg*60;
    
    levelChanges.changeAngle(i) = depthChangeVA;
    
    %finding the distance travelled in visual angle
    if levelChanges.depthChange(i) == fixation(3)
        distanceMovedSection1VA(i) = depthStartVA;
        distanceMovedSection2VA(i) = -depthEndVA;
        
    elseif levelChanges.depthChange(i) < fixation(3) %if the speed change occurs in front of fixation
    distanceMovedSection1VA(i) = depthStartVA - levelChanges.changeAngle(i);
    distanceMovedSection2VA(i) = -depthEndVA + levelChanges.changeAngle(i);
    
    elseif levelChanges.depthChange(i) > fixation(3) %if the speed change occurs behind fixation, as in slow-fast
        distanceMovedSection1VA(i) = depthStartVA - levelChanges.changeAngle(i);
    distanceMovedSection2VA(i) = -depthEndVA + levelChanges.changeAngle(i);
   
    end
end

totalDistancePerIntervalVA = distanceMovedSection1VA + distanceMovedSection2VA;

disp('Total distance moved in interval (arcmin):')
disp(totalDistancePerIntervalVA);
disp('Section 1 distance (arcmin):');
disp(distanceMovedSection1VA);
disp('Section 2 distance (arcmin):');
disp(distanceMovedSection2VA);


    