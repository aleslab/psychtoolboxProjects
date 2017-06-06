function [trialData] = trial_longRangeOccluder(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow = false;
trialData.stimStartTime = t; 

black = BlackIndex(expInfo.curWindow);
gray = GrayIndex(expInfo.curWindow);

rectCircle = conditionInfo.stimSize;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;

rectObs = conditionInfo.rectObs;
ycoord = expInfo.center(2)/2;
xcoordOccluder = expInfo.center(1)/3;
xcoord = expInfo.center(1);
xcoordStim = [xcoord-xcoord/3*2 xcoord xcoord+xcoord/3*2 xcoord xcoord-xcoord/3*2];

Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoord-xcoordOccluder,ycoord))
Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoord+xcoordOccluder,ycoord))


while ~KbCheck
    if strcmp(conditionInfo.label,'simult')
        for pos=1:3
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
        end
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi, 1);
        for pos=1:3
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
        end
        t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi, 1);
    else
        for pos=1:4
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoord));
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
            if strcmp(conditionInfo.label,'expected')
                Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordStim(2),ycoord))
            end
            if strcmp(conditionInfo.label,'unexpected')
                Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectCircle,xcoordStim(2),ycoord))
            end
            t = Screen('Flip', expInfo.curWindow, t + (nbFrames - 0.5) * ifi, 1);
        end
    end
end

end

