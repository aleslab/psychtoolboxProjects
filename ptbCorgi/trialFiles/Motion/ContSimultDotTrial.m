function [trialData] = ContSimultDotTrial(expInfo, conditionInfo)

%AL's code for the dot conditions within the line vs. dots experiment.

% Should have a circular apeture with a 12 degree diameter, split into two
% halves. There should then be 200 dots in each half which wrap around in a
% new location when they disappear. The dots should be ~0.2 deg in
% diameter? and they should be white (like the lines)

trialData.validTrial = true; %Set this to true if you want the trial to be valid for 'generic'
trialData.abortNow   = false;

%Draw fixation. Take the parameters from the default fixation set in
%expInfo.
drawFixation(expInfo, expInfo.fixationInfo);
vbl=Screen('Flip', expInfo.curWindow);

%number of frames based on the duration of the section
nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;

%saving the information about frames to trial data struct
trialData.nFrames.PreStim = nFramesPreStim;
trialData.nFrames.Section1 = nFramesSection1;
trialData.nFrames.Section2 = nFramesSection2;
trialData.nFrames.Total = nFramesTotal;

%velocity conversions to pixels per second
velSection1PixPerSec = conditionInfo.velocityDegPerSecSection1*expInfo.pixPerDeg;
velSection2PixPerSec = conditionInfo.velocityDegPerSecSection2*expInfo.pixPerDeg;

trialData.flipTimes = NaN(nFramesTotal,1);
trialData.dotPositions = NaN(nFramesTotal,1);
frameIdx = 1;

%% creating the moving dots

apXSize = round(3 * expInfo.pixPerDeg); %aperture width in pixels. we want this to be 3 degrees. expInfo.pixPerDeg
apYSize = round(6 * expInfo.pixPerDeg); %aperture height in pixels.
dotSize = 8; %dot size in pixels, may change later
xy1x = randi(apXSize,1,200); %random x positions for dots in the first aperture
xy1y = randi(apYSize,1,200); % as above but for y positions
xymatrix1 = vertcat(xy1x, xy1y); %forms the matrix of xy coordinates for the first aperture of dots

xy2x = randi(apXSize,1,200); %random x positions for dots in second aperture
xy2y = randi(apYSize,1,200); % as above but y positions
xymatrix2 = vertcat(xy2x, xy2y); %forms the matrix of the xy coordinates for the second aperture of dots

xymatrix2(1,:) = bsxfun(@plus, xymatrix2(1,:), apXSize); %moves the position that these dots start to the end position of the first group of dots

DotPos(1) = expInfo.center(1) - (apXSize);
DotPos(2) = expInfo.center(2) - (0.5*apYSize);

curLeftPositions = xymatrix1;
curRightPositions = xymatrix2;

if strcmp(conditionInfo.conditionType, 'continuous')
    
    % Usage of drawdots: [minSmoothPointSize, maxSmoothPointSize, minAliasedPointSize,...
    %maxAliasedPointSize]=...
    %Screen(?DrawDots?, windowPtr, xy [,size] [,color] [,center] [,dot_type][, lenient]);
    
    Screen('DrawDots', expInfo.curWindow, curLeftPositions, dotSize, 1, DotPos, 2); %draw white dots
    Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
    
    drawFixation(expInfo, expInfo.fixationInfo); % drawing the fixation cross
    
    LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
    %trialData.dotPositions(frameIdx) = curPositions; %broken
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    %setting up timings for the experiment
    currentTime = LAT;
    preStimEndTime = LAT + conditionInfo.preStimDuration;
    section1endtime = preStimEndTime + conditionInfo.stimDurationSection1;
    section2endtime = section1endtime + conditionInfo.stimDurationSection2;
    nextFlipTime = LAT+expInfo.ifi/2;
    currIfi = expInfo.ifi;
    previousFlipTime = LAT;
    velocityPixPerSec = 0;
    
    %deciding whether the line should be drawn and what speed should be used in each section
    while currentTime < section2endtime
        
        if currentTime < preStimEndTime %if you're in the 0.25s before motion
            velocityPixPerSec = 0;
            drawLeftDots = true;
            drawRightDots = false;
            
        elseif currentTime > preStimEndTime && currentTime < section1endtime %if you're in section 1
            velocityPixPerSec = velSection1PixPerSec;
            drawLeftDots = true;
            drawRightDots = false;
            
        elseif currentTime > section1endtime && currentTime < section2endtime %if you're in section 2
            velocityPixPerSec = velSection2PixPerSec;
            drawLeftDots = false;
            drawRightDots = true;
            
        else
            velocityPixPerSec = velocityPixPerSec;
            drawLeftDots = false;
            drawRightDots = true;
            
        end
        
        
        if drawLeftDots == true
            
            Screen('DrawDots', expInfo.curWindow, curLeftPositions, dotSize, 1, DotPos, 2); %draw white dots
            %Screen('DrawLines', expInfo.curWindow, [expInfo.center(1), expInfo.center(1); 0, expInfo.windowSizePixels(2)], 1);
            Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
            
            curLeftPositions(1,:) = bsxfun(@plus, curLeftPositions(1,:), (velocityPixPerSec * currIfi)); % adds to each element in vector; in pixels per frame
            
            wrapAroundL = find(curLeftPositions(1,:) >= apXSize);
            curLeftPositions(1,wrapAroundL) = 0;
            
            
            
        elseif drawRightDots == true
            
            Screen('DrawDots', expInfo.curWindow, curRightPositions, dotSize, 1, DotPos, 2); %draw white dots
            %Screen('DrawLines', expInfo.curWindow, [expInfo.center(1), expInfo.center(1); 0, expInfo.windowSizePixels(2)], 1);
            Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
            
            curRightPositions(1,:) = bsxfun(@plus, curRightPositions(1,:), (velocityPixPerSec * currIfi)); % adds to each element in vector; in pixels per frame
            
            wrapAroundR = find(curRightPositions(1,:) >= 2*apXSize);
            curRightPositions(1,wrapAroundR) = apXSize;
            
        end
        
        drawFixation(expInfo, expInfo.fixationInfo); %drawing fixation
        
        %flipping to the screen and getting flip times
        currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
        %trialData.dotPositions(frameIdx) = curPositions; %broken
        trialData.flipTimes(frameIdx) = currentFlipTime;
        frameIdx = frameIdx+1;
        nextFlipTime = currentFlipTime + expInfo.ifi/2;
        currentTime = currentFlipTime;
        currIfi = currentFlipTime - previousFlipTime;
        previousFlipTime = currentFlipTime;
        
    end
    
elseif strcmp(conditionInfo.conditionType, 'simultaneous')
    
    Screen('DrawDots', expInfo.curWindow, curLeftPositions, dotSize, 1, DotPos, 2); %draw white dots
    Screen('DrawDots', expInfo.curWindow, curRightPositions, dotSize, 1, DotPos, 2);
    Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
    
    drawFixation(expInfo, expInfo.fixationInfo); % drawing the fixation cross
    
    LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
    %trialData.dotPositions(frameIdx) = curPositions; %broken
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    %setting up timings for the experiment
    currentTime = LAT;
    preStimEndTime = LAT + conditionInfo.preStimDuration;
    section1endtime = preStimEndTime + conditionInfo.stimDurationSection1;
    section2endtime = section1endtime + conditionInfo.stimDurationSection2;
    nextFlipTime = LAT+expInfo.ifi/2;
    currIfi = expInfo.ifi;
    previousFlipTime = LAT;
    velocity1PixPerSec = 0;
    velocity2PixPerSec = 0;
    
    while currentTime < section1endtime && currentTime < section2endtime
        if currentTime < preStimEndTime %if you're in the 0.25s before motion
            velocity1PixPerSec = 0;
            velocity2PixPerSec = 0;
            
        elseif currentTime > preStimEndTime && currentTime < section1endtime && currentTime < section2endtime
            velocity1PixPerSec = velSection1PixPerSec;
            velocity2PixPerSec = velSection2PixPerSec;
            
        else
            disp('Something broke!');
            velocity1PixPerSec = velocity1PixPerSec;
            velocity2PixPerSec = velocity2PixPerSec;
        end
        
        
        
        Screen('DrawDots', expInfo.curWindow, curLeftPositions, dotSize, 1, DotPos, 2); %draw white dots
        
        Screen('DrawDots', expInfo.curWindow, curRightPositions, dotSize, 1, DotPos, 2); %draw white dots
        
        Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
        
        drawFixation(expInfo, expInfo.fixationInfo); %drawing fixation
        
        curLeftPositions(1,:) = bsxfun(@plus, curLeftPositions(1,:), (velocity1PixPerSec * currIfi)); % adds to each element in vector; in pixels per frame
        curRightPositions(1,:) = bsxfun(@plus, curRightPositions(1,:), (velocity2PixPerSec * currIfi)); % adds to each element in vector; in pixels per frame
        
        wrapAroundL = find(curLeftPositions(1,:) >= apXSize);
        curLeftPositions(1,wrapAroundL) = 0;
        
        wrapAroundR = find(curRightPositions(1,:) >= 2*apXSize);
        curRightPositions(1,wrapAroundR) = apXSize;
        
        %flipping to the screen and getting flip times
        currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
        trialData.flipTimes(frameIdx) = currentFlipTime;
        frameIdx = frameIdx+1;
        nextFlipTime = currentFlipTime + expInfo.ifi/2;
        currentTime = currentFlipTime;
        currIfi = currentFlipTime - previousFlipTime;
        previousFlipTime = currentFlipTime;
        
    end
    
elseif strcmp(conditionInfo.conditionType, 'continuousAlternative')
    
    %create a larger, 6 deg by 6 deg aperture with 400 dots
    
    fullApXSize = round(6 * expInfo.pixPerDeg); %aperture width in pixels. we want this to be 3 degrees. expInfo.pixPerDeg
    fullApYSize = round(6 * expInfo.pixPerDeg); %aperture height in pixels.
    xy1x = randi(fullApXSize,1,400); %random x positions for dots in the full aperture
    xy1y = randi(fullApYSize,1,400); % as above but for y positions
    fullApMatrix = vertcat(xy1x, xy1y); %forms the matrix of xy coordinates for the full aperture of dots
    
    FullApDotPos(1) = expInfo.center(1) - (0.5*fullApXSize);
    FullApDotPos(2) = expInfo.center(2) - (0.5*fullApYSize);
    
    currFullApDotPos = fullApMatrix;
    
    %draw the dots for the static period
    Screen('DrawDots', expInfo.curWindow, currFullApDotPos, dotSize, 1, FullApDotPos, 2); %draw white dots;
    Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
    
    drawFixation(expInfo, expInfo.fixationInfo); % drawing the fixation cross
    
    LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
    %trialData.dotPositions(frameIdx) = curPositions; %broken
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    %setting up timings for the experiment
    currentTime = LAT;
    preStimEndTime = LAT + conditionInfo.preStimDuration;
    section1endtime = preStimEndTime + conditionInfo.stimDurationSection1;
    section2endtime = section1endtime + conditionInfo.stimDurationSection2;
    nextFlipTime = LAT+expInfo.ifi/2;
    currIfi = expInfo.ifi;
    previousFlipTime = LAT;
    velocityPixPerSec = 0;
    
    %deciding whether the line should be drawn and what speed should be used in each section
    while currentTime < section2endtime
        
        if currentTime < preStimEndTime %if you're in the 0.25s before motion
            velocityPixPerSec = 0;
            
        elseif currentTime > preStimEndTime && currentTime < section1endtime %if you're in section 1
            velocityPixPerSec = velSection1PixPerSec;
            
            
        elseif currentTime > section1endtime && currentTime < section2endtime %if you're in section 2
            velocityPixPerSec = velSection2PixPerSec;
            
        else
            velocityPixPerSec = velocityPixPerSec;
            
        end
        
        Screen('DrawDots', expInfo.curWindow, currFullApDotPos, dotSize, 1, FullApDotPos, 2); %draw white dots;
        Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %blending function for the dots
        drawFixation(expInfo, expInfo.fixationInfo); %drawing fixation
        
        currFullApDotPos(1,:) = bsxfun(@plus, currFullApDotPos(1,:), (velocityPixPerSec * currIfi)); % adds to each element in vector; in pixels per frame
        fullWrapAround = find(currFullApDotPos(1,:) >= fullApXSize);
        currFullApDotPos(1,fullWrapAround) = 0;
        
        
        %flipping to the screen and getting flip times
        currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
        trialData.flipTimes(frameIdx) = currentFlipTime;
        frameIdx = frameIdx+1;
        nextFlipTime = currentFlipTime + expInfo.ifi/2;
        currentTime = currentFlipTime;
        currIfi = currentFlipTime - previousFlipTime;
        previousFlipTime = currentFlipTime;
        
    end
    
end