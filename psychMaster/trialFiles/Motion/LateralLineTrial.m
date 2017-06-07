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
velCmPerFrameSection1  = conditionInfo.velocityCmPerSecSection1*expInfo.ifi;
velCmPerFrameSection2  = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;

trialData.flipTimes = NaN(nFramesTotal,1);
frameIdx = 1;

%% Creating the line and the structure of the stimulus presentation

pixelStartPos = round(expInfo.center(1) + (expInfo.pixPerCm * conditionInfo.startPos));
%finding the pixel start position relative to the centre of the screen
%(left of screen centre is - and right is +) converting from the cm value
%given in the paradigm file

currLinePos = pixelStartPos;

for iFrame = 1:nFramesPreStim %during the pre stimulus duration
    
    %drawing the line at the current line position (in the x axis) from the
    %top to the bottom of the screen
    Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], expInfo.lw);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
end

for iFrame = 1:nFramesSection1
    
    Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], expInfo.lw);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    currLinePos = currLinePos + velCmPerFrameSection1;
end

if conditionInfo.temporalGap > 0
    
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    WaitSecs(conditionInfo.temporalGap);
    
end

for iFrame = 1:nFramesSection2
    
    Screen('DrawLines', expInfo.curWindow, [currLinePos, currLinePos; 0, screenYpixels], expInfo.lw);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    currLinePos = currLinePos + velCmPerFrameSection2;
    
end




end