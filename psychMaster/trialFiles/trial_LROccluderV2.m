function [trialData] = trial_LROccluderV2(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow = false;
trialData.trialStartTime = t;

black = BlackIndex(expInfo.curWindow);
gray = GrayIndex(expInfo.curWindow);

% parameters
rectCircle = conditionInfo.stimSize;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;
rectObs = conditionInfo.rectObs;
ycoord = expInfo.center(2)/2;
xcoordOccluder = expInfo.center(1)/3;
xcoord = expInfo.center(1);
% for the task: pick a random number of test trials and when they will be
% presented, not during the 1st and last second of the trial (where the EEG
% recording will be cut)
trialData.testFlipNb = randi(conditionInfo.maxTest+1,1)-1; % number of tests for this trial
trialData.testFlipFrame = randsample(8:2:conditionInfo.totFlip-7, trialData.testFlipNb) - 1; % '-1' because 1st flip = 0

% 3 possible locations of the stimuli, the last two are for 'boucler la
% boucle' in the motion condition (not simult)
xcoordStim = [xcoord-xcoord/3*2 xcoord xcoord+xcoord/3*2 xcoord xcoord-xcoord/3*2];

% draw the rectangles that are always present
Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoord-xcoordOccluder,ycoord))
Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoord+xcoordOccluder,ycoord))

flipNb = 0; % keep track of the number of flips
stimStartTime = trialData.trialStartTime; % this is wrong but need a starting value for the while loop

% presentation stimulus
while ~KbCheck && t<conditionInfo.stimDuration+stimStartTime-ifi/2
    if strcmp(conditionInfo.label,'simult')
        for pos=1:3 % draw an oval in all 3 locations
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
        if flipNb == 1
            stimStartTime = t;
        end
        for pos=1:3 % draw a gray oval (= background) in all 3 locations = no stim
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
    else % motion - for explanation, see below
        for pos=1:4
            Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectObs,xcoordStim(1),ycoord)); % has to draw it in case it was black the previous frame
            Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectObs,xcoordStim(3),ycoord)); % has to draw it in case it was black the previous frame
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoord));
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoord));
            if ismember(flipNb,trialData.testFlipFrame)
                if strcmp(conditionInfo.label,'expected')
                    Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordStim(pos+1),ycoord));
                end
                if strcmp(conditionInfo.label,'unexpected')
                    Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoord));
                end
            end
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
            flipNb = flipNb+ 1;
            if flipNb == 1
                stimStartTime = t;
            end
        end
    end
end
trialData.stimStartTime = stimStartTime;
trialData.stimEndTime = t;

% each time 1 stim is drawn in black and one in gray (=background
% =disappears). there are 4 possible states (for the stim to go from
% center, right, center, left, center), repeated until keyPress.
% the expected / unexpected conditions can happen only at state 1 or 3
% (that is when the stim is in the center).

% abort
[keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
if keyIsDown
    trialData.validTrial = false;
    if keyCode(KbName('escape'))
        trialData.abortNow   = true;
    end
end


trialData.totFlip = flipNb;
if flipNb ~= conditionInfo.totFlip
    trialData.validTrial = false;
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.stimDurationReal = trialData.stimEndTime - trialData.stimStartTime ; 
trialData.trialDurationReal = trialData.trialEndTime - trialData.trialStartTime ; 

% trialData

end

