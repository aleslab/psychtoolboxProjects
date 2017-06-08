function [trialData] = trial_longRangeSweep(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.stimStartTime = t; 

black = BlackIndex(expInfo.curWindow);

rectCircle = conditionInfo.stimSize;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;
ycoord = expInfo.center(2)/2;
xcoord = expInfo.center(1)/conditionInfo.xloc(1);
xcoordEnd = expInfo.center(1)/conditionInfo.xloc(2);

while ~KbCheck || xcoord<xcoordEnd+1
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
    t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
    t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
    xcoord = xcoord + 1;
end


end

