
%% calculateScreenLocation other important inputs
eyeL = [-3,0,0]; %left eye position
eyeR = [3,0,0]; %right eye position
fixation = [0,0,97]; %viewing distance
depthStart = fixation + [0, 0, 20]; %the start position of the lines in depth
depthEnd = fixation + [0, 0, -20]; %the end position of the lines in depth

totalDistances = repmat(40,1,7); %the total distance travelled in an interval
section1distances = [20 22.5 25 27.5 30 32.5 35]; %the distance travelled in section 1 of an interval
section2distances = totalDistances - section1distances; %the distance travelled in section 2 of an interval
levelChanges = struct();

%% Screen locations in degrees for an object moving in depth

[screenLstart, screenRstart] = calculateScreenLocation(fixation, depthStart, eyeL, eyeR);
%calculates the start position on each screen half in cm for the object in depth
%to be in that position

[screenLend, screenRend] = calculateScreenLocation(fixation, depthEnd, eyeL, eyeR);
% calculates the end position of the lines on each screen half

for i = 1:length(totalDistances);
    
    changePos = depthStart - [0, 0, section1distances(i)];
    
    [screenLchange, screenRchange] = calculateScreenLocation(fixation, changePos, eyeL, eyeR);
    
    levelChanges.depthChange(i) = changePos(3);
    
    levelChanges.screenLChangePos(i) = screenLchange(1);
    levelChanges.screenRChangePos(i) = screenRchange(1);
    
end

%finding the start position in visual angle
depthStartrad = atan(screenLstart(1)/97);
depthStartdeg = rad2deg(depthStartrad);
depthStartVA = depthStartdeg*60;

levelChanges.startAngle = depthStartVA;

%finding the end position in visual angle
depthEndrad = atan(screenLend(1)/97);
depthEnddeg = rad2deg(depthEndrad);
depthEndVA = depthEnddeg*60;

levelChanges.startAngle = depthStartVA;

%finding the position of the speed change in visual angle
for i = 1:length(levelChanges.depthChange);
    
    change = [levelChanges.screenLChangePos(i)];
    depthChangerad = atan(change/97);
    depthChangedeg = rad2deg(depthChangerad);
    depthChangeVA = depthChangedeg*60;
    
    levelChanges.changeAngle(i) = depthChangeVA;
    
end


%if levelChanges.depthChange(i) < fixation(3)


