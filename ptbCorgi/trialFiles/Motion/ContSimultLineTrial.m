function [trialData] = ContSimultLineTrial(expInfo, conditionInfo)
%AL's code for the line conditions within the line vs. dots experiment.
%Adapted from AL's LateralLineTrial.m

%% Setup

screenYpixels = expInfo.windowSizePixels(2); %the height of the screen

trialData.validTrial = true; %Set this to true if you want the trial to be valid for 'generic'
trialData.abortNow   = false;

lw = 1; %width of line is one pixel

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
gapVelocityPixPerSec = conditionInfo.gapVelocity*expInfo.pixPerDeg;

trialData.flipTimes = NaN(nFramesTotal,1);
trialData.LinePos = NaN(nFramesTotal,1);
frameIdx = 1;

%% Creating the moving line

pixelStartPos = (expInfo.center(1) + round(expInfo.pixPerDeg * conditionInfo.startPos));
%finding the pixel start position relative to the centre of the screen
%(left of screen centre is - and right is +) converting from the cm value
%given in the paradigm file

if strcmp(conditionInfo.conditionType, 'continuous')
    
    currLinePos = pixelStartPos;
    
    %drawing the line at the current line position (in the x axis) from the
    %top to the bottom of the screen
    Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], lw); %drawing a line the full height of the screen
    drawFixation(expInfo, expInfo.fixationInfo); % drawing the fixation cross
    LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
    trialData.LinePos(frameIdx) = currLinePos;
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
            drawLine = true;
            
        elseif currentTime > preStimEndTime && currentTime < section1endtime %if you're in section 1
            velocityPixPerSec = velSection1PixPerSec;
            drawLine = true;
            
        elseif currentTime > section1endtime && currentTime < section2endtime %if you're in section 2
            velocityPixPerSec = velSection2PixPerSec;
            drawLine = true;
            
        else
            velocityPixPerSec = velocityPixPerSec;
            drawLine = true;
        end
        
        currLinePos = currLinePos + velocityPixPerSec * currIfi; %currLinePos is in pixels per frame
        
        if drawLine == true
            
            Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], lw);
            
        end
        
        drawFixation(expInfo, expInfo.fixationInfo); %drawing fixation
        
        %flipping to the screen and getting flip times
        currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
        trialData.LinePos(frameIdx) = currLinePos;
        trialData.flipTimes(frameIdx) = currentFlipTime;
        frameIdx = frameIdx+1;
        nextFlipTime = currentFlipTime + expInfo.ifi/2;
        currentTime = currentFlipTime;
        currIfi = currentFlipTime - previousFlipTime;
        previousFlipTime = currentFlipTime;
        
    end
    
elseif strcmp(conditionInfo.conditionType, 'simultaneous')
    
    currLine1Pos = pixelStartPos; % the first line starts at the start position
    currLine2Pos = pixelStartPos + (conditionInfo.stimDurationSection1 * ...
        conditionInfo.velocityDegPerSecSection1 * expInfo.pixPerDeg); % the second line will start where the first line will finish
    
    %drawing the line at the current line position (in the x axis) from the
    %top to the bottom of the screen
    Screen('DrawLines', expInfo.curWindow, [currLine1Pos, currLine1Pos, currLine2Pos, currLine2Pos;...
        0, screenYpixels, 0, screenYpixels], lw); %drawing two lines the full height of the screen
    drawFixation(expInfo, expInfo.fixationInfo); % drawing the fixation cross
    
    LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
    trialData.Line1Pos(frameIdx) = currLine1Pos;
    trialData.Line2Pos(frameIdx) = currLine2Pos;
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    %setting up timings for the experiment
    currentTime = LAT;
    preStimEndTime = LAT + conditionInfo.preStimDuration;
    section1endtime = preStimEndTime + conditionInfo.stimDurationSection1;
    section2endtime = preStimEndTime + conditionInfo.stimDurationSection2;
    nextFlipTime = LAT+expInfo.ifi/2;
    currIfi = expInfo.ifi;
    previousFlipTime = LAT;
    velocity1PixPerSec = 0;
    velocity2PixPerSec = 0;
    
    while currentTime < section1endtime && currentTime < section2endtime
        if currentTime < preStimEndTime %if you're in the 0.25s before motion
            velocity1PixPerSec = 0;
            velocity2PixPerSec = 0;
            drawLine = true;
            
        elseif currentTime > preStimEndTime && currentTime < section1endtime && currentTime < section2endtime
            velocity1PixPerSec = velSection1PixPerSec;
            velocity2PixPerSec = velSection2PixPerSec;
            drawLine = true;
            
        else
            disp('Something broke!');
            velocity1PixPerSec = velocity1PixPerSec;
            velocity2PixPerSec = velocity2PixPerSec;
            drawLine = true;
        end
        
        currLine1Pos = currLine1Pos + velocity1PixPerSec * currIfi; % in pixels per frame
        currLine2Pos = currLine2Pos + velocity2PixPerSec * currIfi; % in pixels per frame
        
        if drawLine == true
            
            Screen('DrawLines', expInfo.curWindow, [currLine1Pos, currLine1Pos, currLine2Pos, currLine2Pos;...
                0, screenYpixels, 0, screenYpixels], lw);
            
        end
        
        drawFixation(expInfo, expInfo.fixationInfo); %drawing fixation
        
        %flipping to the screen and getting flip times
        currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
        trialData.Line1Pos(frameIdx) = currLine1Pos;
        trialData.Line2Pos(frameIdx) = currLine2Pos;
        trialData.flipTimes(frameIdx) = currentFlipTime;
        frameIdx = frameIdx+1;
        nextFlipTime = currentFlipTime + expInfo.ifi/2;
        currentTime = currentFlipTime;
        currIfi = currentFlipTime - previousFlipTime;
        previousFlipTime = currentFlipTime;
        
    end
end
