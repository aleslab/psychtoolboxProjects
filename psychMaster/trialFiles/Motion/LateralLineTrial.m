function [trialData] = LateralLineTrial(expInfo, conditionInfo)

%trial code for AL's lateral moving line experiments - not accelerating or
%motion in depth, lateral lines moving at constant retinal speed for
%temporal integration experiments.

%% Setup

[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);

trialData.validTrial = false;
trialData.abortNow   = false;

expInfo.lw = 1; %width of line is one pixel

%initial fixation information
fixationInfo(1).type    = 'cross';
fixationInfo(1).fixLineWidthPix = 1;
expInfo = drawFixation(expInfo, fixationInfo);


vbl=Screen('Flip', expInfo.curWindow);

%number of frames based on the duration of the section. might change this
%later based on how i decide to deal with time/distance/speed in the
%paradigm files. May make fixed distance in which case the duration of the
%second may be variable.
nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;

%saving the information about frames to trial data struct
trialData.nFrames.PreStim = nFramesPreStim;
trialData.nFrames.Section1 = nFramesSection1;
trialData.nFrames.Section2 = nFramesSection2;
trialData.nFrames.Total = nFramesTotal;

%cm/frame velocity
% velCmPerFrameSection1  = conditionInfo.velocityCmPerSecSection1*expInfo.ifi;
% velCmPerFrameSection2  = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;

velSection1PixPerSec = conditionInfo.velocityDegPerSecSection1*expInfo.ppd;
velSection2PixPerSec = conditionInfo.velocityDegPerSecSection2*expInfo.ppd;
gapVelocityPixPerSec = conditionInfo.gapVelocity*expInfo.ppd;

trialData.flipTimes = NaN(nFramesTotal,1);
frameIdx = 1;

%% Creating the line and the structure of the stimulus presentation

pixelStartPos = (expInfo.center(1) + round(expInfo.ppd * conditionInfo.startPos));
%finding the pixel start position relative to the centre of the screen
%(left of screen centre is - and right is +) converting from the cm value
%given in the paradigm file

currLinePos = pixelStartPos;

%drawing the line at the current line position (in the x axis) from the
%top to the bottom of the screen
Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], expInfo.lw);
expInfo = drawFixation(expInfo, fixationInfo);
LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
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
waitTime = 0;
while currentTime < section2endtime
    
    if currentTime < preStimEndTime
        velocityPixPerSec = 0;
        drawLine = true;
        
    elseif currentTime > preStimEndTime && currentTime < section1endtime
        velocityPixPerSec = velSection1PixPerSec;
        drawLine = true;
        
    elseif currentTime > section1endtime && currentTime < gapendtime
        velocityPixPerSec = gapVelocityPixPerSec;
        drawLine = false;
        
    elseif currentTime > gapendtime && currentTime < section2endtime
        velocityPixPerSec = velSection2PixPerSec;
        drawLine = true;
        
    else
        velocityPixPerSec = velocityPixPerSec;
        drawLine = true;
        
    end
    
    currLinePos = currLinePos + velocityPixPerSec * currIfi; %currLinePos is in pixels per frame
    
    if drawLine == true
        
        Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], expInfo.lw);
        
    end
    expInfo = drawFixation(expInfo, fixationInfo);
    currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
    trialData.flipTimes(frameIdx) = currentFlipTime;
    frameIdx = frameIdx+1;
    nextFlipTime = currentFlipTime + expInfo.ifi/2;
    currentTime = currentFlipTime;
    currIfi = currentFlipTime - previousFlipTime;
    previousFlipTime = currentFlipTime;   

end

end