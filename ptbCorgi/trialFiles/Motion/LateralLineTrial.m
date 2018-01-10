function [trialData] = LateralLineTrial(expInfo, conditionInfo)

%trial code for AL's lateral moving line experiments - not accelerating or
%motion in depth, lateral lines moving at constant retinal speed for
%temporal integration experiments.

%% Setup

screenYpixels = expInfo.windowSizePixels(2);

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

velSection1PixPerSec = conditionInfo.velocityDegPerSecSection1*expInfo.pixPerDeg;
velSection2PixPerSec = conditionInfo.velocityDegPerSecSection2*expInfo.pixPerDeg;
gapVelocityPixPerSec = conditionInfo.gapVelocity*expInfo.pixPerDeg;

trialData.flipTimes = NaN(nFramesTotal,1);
trialData.LinePos = NaN(nFramesTotal,1);
frameIdx = 1;

%% Creating the line and the structure of the stimulus presentation

if isfield(conditionInfo,'shortLines') && conditionInfo.shortLines
    
    shortLines = true;
    spatialGap = conditionInfo.spatialGap;
    
    pixelSpatialGap = round(expInfo.pixPerDeg * spatialGap);
    
    lineYStartPos = round(expInfo.center(2) -2*expInfo.pixPerDeg -0.5*pixelSpatialGap);
    lineYS2StartPos = round(expInfo.center(2) -2*expInfo.pixPerDeg +0.5*pixelSpatialGap);
    lineYEndPos = round(lineYStartPos + 4*expInfo.pixPerDeg);
    lineYS2EndPos = round(lineYS2StartPos + 4*expInfo.pixPerDeg);
    
else
    lineYStartPos = 0;
    lineYEndPos = screenYpixels;
    shortLines = false;
end

pixelStartPos = (expInfo.center(1) + round(expInfo.pixPerDeg * conditionInfo.startPos));
%finding the pixel start position relative to the centre of the screen
%(left of screen centre is - and right is +) converting from the cm value
%given in the paradigm file

currLinePos = pixelStartPos;

%drawing the line at the current line position (in the x axis) from the
%top to the bottom of the screen
Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; lineYStartPos, lineYEndPos], lw);
drawFixation(expInfo, expInfo.fixationInfo);
LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
trialData.LinePos(frameIdx) = currLinePos;
trialData.flipTimes(frameIdx) = vbl;
frameIdx = frameIdx+1;

currentTime = LAT;
preStimEndTime = LAT + conditionInfo.preStimDuration;
section1endtime = preStimEndTime + conditionInfo.stimDurationSection1;
gapendtime = section1endtime + conditionInfo.temporalGap;
section2endtime = gapendtime + conditionInfo.stimDurationSection2;

nextFlipTime = LAT+expInfo.ifi/2;
currIfi = expInfo.ifi;
previousFlipTime = LAT;
velocityPixPerSec = 0;

while currentTime < section2endtime
    
    if currentTime < preStimEndTime
        velocityPixPerSec = 0;
        drawLine = true;
        s2offsetDrawLine = false;
        
    elseif currentTime > preStimEndTime && currentTime < section1endtime
        velocityPixPerSec = velSection1PixPerSec;
        drawLine = true;
        s2offsetDrawLine = false;
        
    elseif currentTime > section1endtime && currentTime < gapendtime
        velocityPixPerSec = gapVelocityPixPerSec;
        drawLine = false;
        s2offsetDrawLine = false;
        
    elseif currentTime > gapendtime && currentTime < section2endtime && ~shortLines
        velocityPixPerSec = velSection2PixPerSec;
        drawLine = true;
        s2offsetDrawLine = false;
        
    elseif currentTime > gapendtime && currentTime < section2endtime && shortLines
        velocityPixPerSec = velSection2PixPerSec;
        drawLine = false;
        s2offsetDrawLine = true;
        
    else
        velocityPixPerSec = velocityPixPerSec;
        drawLine = true;
        s2offsetDrawLine = false;
    end
    
    currLinePos = currLinePos + velocityPixPerSec * currIfi; %currLinePos is in pixels per frame
    
    if s2offsetDrawLine == true
        
        Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; lineYS2StartPos, lineYS2EndPos], lw);
        
    end
    
    
    if drawLine == true
        
        Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; lineYStartPos, lineYEndPos], lw);
        
    end
    
    
    
    drawFixation(expInfo, expInfo.fixationInfo);
    currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
    trialData.LinePos(frameIdx) = currLinePos;
    trialData.flipTimes(frameIdx) = currentFlipTime;
    frameIdx = frameIdx+1;
    nextFlipTime = currentFlipTime + expInfo.ifi/2;
    currentTime = currentFlipTime;
    currIfi = currentFlipTime - previousFlipTime;
    previousFlipTime = currentFlipTime;
    
end
% 
% %After the line moves we'll turn off the line and turn on a response
% %indicator
% %
% 
% responseIndicator.type = 'square';
% responseIndicator.size = .4;
% 
% drawFixation(expInfo, expInfo.fixationInfo);
% % drawFixation(expInfo, responseIndicator);
% 
% currentFlipTime = Screen('Flip', expInfo.curWindow);


end