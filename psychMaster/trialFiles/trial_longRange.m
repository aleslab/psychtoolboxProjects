function [trialData] = trial_longRange(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t; 

black = BlackIndex(expInfo.curWindow);

rectCircle = conditionInfo.stimSize;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;
ycoord = expInfo.center(2)/2;
xcoord = expInfo.center(1)/conditionInfo.xloc(1);
if strcmp(conditionInfo.label,'sweep')
    xcoordEnd = expInfo.center(1)/conditionInfo.xloc(2);
    movingStep = conditionInfo.movingStep;
else
    xcoordEnd = expInfo.center(1)/conditionInfo.xloc(1);
end

while ~KbCheck && xcoord<xcoordEnd+1
    if strcmp(conditionInfo.sideStim,'both')
        if conditionInfo.motion == 1
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
            if strcmp(conditionInfo.label,'sweep')
                xcoord = xcoord + movingStep;
            end
        else
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
            drawFixation(expInfo, expInfo.fixationInfo);
            t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
        end
    elseif strcmp(conditionInfo.sideStim,'left')
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
        drawFixation(expInfo, expInfo.fixationInfo);
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
    elseif strcmp(conditionInfo.sideStim,'right')
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillOval', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
        drawFixation(expInfo, expInfo.fixationInfo);
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi);
    end
end

trialData.trialEndTime = t; 

end

