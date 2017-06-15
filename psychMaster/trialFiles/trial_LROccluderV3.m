function [trialData] = trial_LROccluderV3(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow,[],1);
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
ycoordUp = expInfo.center(2)/3;
ycoordDown = ycoordUp*2;
xcoord = expInfo.center(1);
divXcoord = expInfo.center(1)/4;
xcoordOccluder = [expInfo.center(1)/2 expInfo.center(1) expInfo.center(1)+expInfo.center(1)/2];

% for the task: pick a random number of test trials and when they will be
% presented, not during the 1st and last second of the trial (where the EEG
% recording will be cut) 
% do not choose stim in the corner (change of visual illusion)
trialData.testFlipNb = randi(conditionInfo.maxTest+1,1)-1; % number of tests for this trial
trialData.testFlipFrame = sort(randsample([9:4:conditionInfo.totFlip-6, 10:4:conditionInfo.totFlip-6], trialData.testFlipNb)); 
while ismember(1,diff(trialData.testFlipFrame)==1) % do it again until there is no 2 successive flips
    trialData.testFlipFrame = sort(randsample([9:4:conditionInfo.totFlip-6, 10:4:conditionInfo.totFlip-6], trialData.testFlipNb));
end
trialData.testFlipSeq = floor(trialData.testFlipFrame/8); % find which sequence contains a test, important for presenting the obstruder at the beginning of the sequence in the expected condition


% 8 possible locations of the stimuli, the last ones are for 'boucler la
% boucle' in the motion condition (not simult)
xcoordStim = [xcoord-divXcoord*3 xcoord-divXcoord*3 xcoord-divXcoord xcoord+divXcoord xcoord+divXcoord*3 ...
    xcoord+divXcoord*3 xcoord+divXcoord xcoord-divXcoord xcoord-divXcoord*3 ];
ycoordStim = [ycoordDown ycoordUp ycoordUp ycoordUp ycoordUp ycoordDown ycoordDown ycoordDown ycoordDown]; 

% draw the rectangles that are always present
for loc=1:length(xcoordOccluder)
    Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordOccluder(loc),ycoordUp));
    Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordOccluder(loc),ycoordDown));
end
Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint([0 0 expInfo.windowSizePixels(1) 20],expInfo.center(1),expInfo.center(2)-expInfo.center(2)/2));

flipNb = 0; % keep track of the number of flips
stimStartTime = trialData.trialStartTime; % this is wrong but need a starting value for the while loop
seq = 0;seqObs=[];
% flip = trialData.testFlipFrame

% presentation stimulus
while ~KbCheck && t<conditionInfo.stimDuration+stimStartTime-ifi/2
    if strcmp(conditionInfo.label,'simult')
        for pos=1:length(xcoordStim)-1 % draw an oval in all locations
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordUp));
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordDown));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
        if flipNb == 1
            stimStartTime = t;
        end
        for pos=1:length(xcoordStim)-1 % draw a gray oval (= background) in all locations = no stim
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordUp));
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordDown));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
    else % motion - for explanation, see below
        for pos=1:length(xcoordStim)-1
            if ismember(seq, trialData.testFlipSeq+1) && strcmp(conditionInfo.label,'expected') % put back in grey for the next sequence
                for ss = 1:length(seqObsOld)
                    Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectObs,xcoordStim((seqObsOld(ss)-8*(seq-1))+1),ycoordStim((seqObsOld(ss)-8*(seq-1))+1)));
                end
            end
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoordStim(pos+1)));
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordStim(pos)));
            if ismember(seq, trialData.testFlipSeq) && strcmp(conditionInfo.label,'expected')
                seqObs = trialData.testFlipFrame(find(trialData.testFlipFrame>8*seq & trialData.testFlipFrame < 8*(seq+1)))+1;
                for ss = 1:length(seqObs)
                    Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordStim((seqObs(ss)-8*seq)+1),ycoordStim((seqObs(ss)-8*seq)+1)));
                end
            end
            if ismember(flipNb,trialData.testFlipFrame) && strcmp(conditionInfo.label,'unexpected')
                Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoordStim(pos+1)));
            end
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
            flipNb = flipNb+ 1;
            if flipNb == 1
                stimStartTime = t;
            end
        end
        seq = seq + 1;
        seqObsOld = seqObs;
    end
end
trialData.stimStartTime = stimStartTime;
trialData.stimEndTime = t;
% trialData.totalSeq = seq;

% each time 1 stim is drawn in black and one in gray (=background
% =disappears). there are 6 (+1repeat) possible states (for the stim to go from
% center up, right up, right down, centre down, left down, left up, center up), repeated until keyPress.
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
% if flipNb ~= conditionInfo.totFlip
%     trialData.validTrial = false;
% end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.stimDurationReal = trialData.stimEndTime - trialData.stimStartTime ; 
trialData.trialDurationReal = trialData.trialEndTime - trialData.trialStartTime ; 

% trialData

end

