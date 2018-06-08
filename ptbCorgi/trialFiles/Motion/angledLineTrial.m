function [trialData] = angledLineTrial(expInfo, conditionInfo)

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

lineLength = conditionInfo.lineLength; %the length of the angled line (hypoteneuse)
XlineAngle = conditionInfo.lineAngle;
YlineAngle = 90 - XlineAngle; %180 degrees in triangle, always want
%right-angled triangle here, so this angle is 90-the other angle

% A/sin(a) = B/sin(b) -> B = Asin(b)/sin(a)
%speeds in section 1 and section 2, separated into X and Y components in
%deg/s
vel1Xdeg = (conditionInfo.velocityDegPerSecSection1*sind(XlineAngle))/sind(90);
vel1Ydeg = (conditionInfo.velocityDegPerSecSection1*sind(YlineAngle))/sind(90);
vel2Xdeg = (conditionInfo.velocityDegPerSecSection2*sind(XlineAngle))/sind(90);
vel2Ydeg = (conditionInfo.velocityDegPerSecSection2*sind(YlineAngle))/sind(90);

%speeds in section 1 and section 2, separated into X and Y components in
%pixels per second
vel1Xpps = vel1Xdeg*expInfo.pixPerDeg;
vel1Ypps = vel1Ydeg*expInfo.pixPerDeg;
vel2Xpps = vel2Xdeg*expInfo.pixPerDeg;
vel2Ypps = vel2Ydeg*expInfo.pixPerDeg;

velGapXpps = conditionInfo.gapVelocity*expInfo.pixPerDeg;
velGapYpps = conditionInfo.gapVelocity*expInfo.pixPerDeg; %this only works 
%if the gap velocity is 0, which for now it is. If I want to change the 
%gap velocity I will need to change this.

trialData.flipTimes = NaN(nFramesTotal,1);
trialData.LinePos = NaN(nFramesTotal,1);
frameIdx = 1;

%% Creating the line and the structure of the stimulus presentation

%the start and end positions of the lines in terms of x and y coordinates
lineXStartPos = (expInfo.center(1) + round(expInfo.pixPerDeg * conditionInfo.startPos));
%finding the pixel start position relative to the centre of the screen
%(left of screen centre is - and right is +) converting from the deg value
%given in the paradigm file
lineXEndPos = lineXStartPos + round((lineLength*sin(XlineAngle))/sind(90) * expInfo.pixPerDeg); %lineXlength = lineLength*sin(xlineAngle)/sin90
lineYStartPos = -4 * expInfo.pixPerDeg;
lineYEndPos = lineYStartPos - round((lineLength*sin(YlineAngle))/sind(90) * expInfo.pixPerDeg);

currXLineStartPos = lineXStartPos;
currXLineEndPos = lineXEndPos;
currYLineStartPos = lineYStartPos;
currYLineEndPos = lineYEndPos;

%drawing the line at the current line position (in the x axis) from the
%top to the bottom of the screen
Screen('DrawLines', expInfo.curWindow, [currXLineStartPos, currXLineEndPos; currYLineStartPos, currYLineEndPos], lw);
drawFixation(expInfo, expInfo.fixationInfo);
LAT = Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %line appearance time
trialData.XLineStartPos(frameIdx) = currXLineStartPos;
trialData.XLineEndPos(frameIdx) = currXLineEndPos;
trialData.YLineStartPos(frameIdx) = currYLineStartPos;
trialData.YLineEndPos(frameIdx) = currYLineEndPos;
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
XvelocityPixPerSec = 0;
YvelocityPixPerSec = 0;

while currentTime < section2endtime
    
    if currentTime < preStimEndTime
        XvelocityPixPerSec = 0;
        YvelocityPixPerSec = 0;
        drawLine = true;
        
    elseif currentTime > preStimEndTime && currentTime < section1endtime
        XvelocityPixPerSec = vel1Xpps;
        YvelocityPixPerSec = vel1Ypps;
        drawLine = true;
        
    elseif currentTime > section1endtime && currentTime < gapendtime
        XvelocityPixPerSec = velGapXpps;
        YvelocityPixPerSec = velGapYpps;
        drawLine = false;
        
    elseif currentTime > gapendtime && currentTime < section2endtime
        XvelocityPixPerSec = vel2Xpps;
        YvelocityPixPerSec = vel2Ypps;
        drawLine = true;
        
    end
    
    currXLineStartPos = currXLineStartPos + XvelocityPixPerSec * currIfi; %in pixels per frame
    currXLineEndPos = currXLineEndPos + XvelocityPixPerSec * currIfi;
    currYLineStartPos = currYLineStartPos + YvelocityPixPerSec * currIfi; %in pixels per frame
    currYLineEndPos = currYLineEndPos + YvelocityPixPerSec * currIfi; 
    
    if drawLine == true
        
        Screen('DrawLines', expInfo.curWindow, [currXLineStartPos, currXLineEndPos; currYLineStartPos, currYLineEndPos], lw);
        
    end
    
    drawFixation(expInfo, expInfo.fixationInfo);
    currentFlipTime = Screen('Flip', expInfo.curWindow,nextFlipTime);
    
    trialData.XLineStartPos(frameIdx) = currXLineStartPos;
    trialData.XLineEndPos(frameIdx) = currXLineEndPos;
    trialData.YLineStartPos(frameIdx) = currYLineStartPos;
    trialData.YLineEndPos(frameIdx) = currYLineEndPos;
    trialData.flipTimes(frameIdx) = currentFlipTime;
    frameIdx = frameIdx+1;
    nextFlipTime = currentFlipTime + expInfo.ifi/2;
    currentTime = currentFlipTime;
    currIfi = currentFlipTime - previousFlipTime;
    previousFlipTime = currentFlipTime;
    
end

end