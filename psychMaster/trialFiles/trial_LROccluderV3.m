function [trialData] = trial_LROccluderV3(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow,[],1);
trialData.validTrial = true;
trialData.abortNow = false;
trialData.trialStartTime = t;

black = BlackIndex(expInfo.curWindow);
gray = GrayIndex(expInfo.curWindow);

% parameters
rectCircle = conditionInfo.stimSize*expInfo.ppd;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;
rectObs = conditionInfo.rectObs*expInfo.ppd;
% ycoordUp = expInfo.center(2)/3;
% ycoordDown = ycoordUp*2;
xcoord = expInfo.center(1);
ycoord = expInfo.center(1);
divXcoord = expInfo.center(1)/4;
divYcoord = expInfo.center(2)/4;

% % 8 possible locations of the stimuli, the last ones are for 'boucler la
% % boucle' in the motion condition (not simult)
% xcoordStim = [xcoord-divXcoord*3 xcoord-divXcoord*3 xcoord-divXcoord xcoord+divXcoord xcoord+divXcoord*3 ...
%     xcoord+divXcoord*3 xcoord+divXcoord xcoord-divXcoord xcoord-divXcoord*3 ];
% ycoordStim = [ycoordDown ycoordUp ycoordUp ycoordUp ycoordUp ycoordDown ycoordDown ycoordDown ycoordDown]; 
% 8 possible locations of the stimuli, the last ones are for 'boucler la
% boucle' in the motion condition (not simult)

xcoordStim = [xcoord-divXcoord*3 xcoord-divXcoord*3 xcoord-divXcoord xcoord+divXcoord xcoord+divXcoord*3 ...
    xcoord+divXcoord*3 xcoord+divXcoord*3 xcoord+divXcoord*3 xcoord+divXcoord xcoord-divXcoord xcoord-divXcoord*3 ...
    xcoord-divXcoord*3 xcoord-divXcoord*3];
ycoordStim = [ycoord-divYcoord ycoord-divYcoord*3 ycoord-divYcoord*3 ycoord-divYcoord*3 ycoord-divYcoord*3 ...
    ycoord-divYcoord ycoord+divYcoord ycoord+divYcoord*3 ycoord+divYcoord*3 ycoord+divYcoord*3 ycoord+divYcoord*3 ...
    ycoord+divYcoord ycoord-divYcoord];
xcoordOccluders = [xcoord-divXcoord*2 xcoord xcoord+divXcoord*2 xcoord+divXcoord*3 xcoord+divXcoord*3 xcoord+divXcoord*3 ...
    xcoord+divXcoord*2 xcoord xcoord-divXcoord*2 xcoord-divXcoord*3 xcoord-divXcoord*3 xcoord-divXcoord*3];
ycoordOccluders = [ycoord-divYcoord*3 ycoord-divYcoord*3 ycoord-divYcoord*3 ycoord-divYcoord*2 ycoord ycoord+divYcoord*2 ...
    ycoord+divYcoord*3 ycoord+divYcoord*3 ycoord+divYcoord*3 ycoord+divYcoord*2 ycoord ycoord-divYcoord*2];
totLoc = length(xcoordStim)-1; % need to know the number of total locations for drawing stim


% for the task: pick a random number of test trials and when they will be
% presented, not during the 1st and last second of the trial (where the EEG
% recording will be cut) - start after the 1st sequence since I present
% obstruders only at the beginning of the sequence
% do not choose stim in the corner (change of visual illusion)
trialData.testFlipNb = randi(conditionInfo.maxTest+1,1)-1; % number of tests for this trial
trialData.testFlipFrame = sort(randsample([14:3:conditionInfo.totFlip-6, 15:3:conditionInfo.totFlip-6], trialData.testFlipNb)); 
while ismember(1,diff(trialData.testFlipFrame)==1) % do it again until there is no 2 successive flips
    trialData.testFlipFrame = sort(randsample([14:3:conditionInfo.totFlip-6, 15:3:conditionInfo.totFlip-6], trialData.testFlipNb)); 
end
trialData.testFlipSeq = floor((trialData.testFlipFrame-1)/totLoc); % find which sequence contains a test, important for presenting the obstruder at the beginning of the sequence in the expected condition


% draw the occluders that are always present
% % the following draws a grill which is not that good
% if expInfo.occluder
%     for loc=1:length(xcoordOccluders)
%         Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint([0 0 expInfo.windowSizePixels(1) 20],expInfo.center(1),ycoordOccluders(loc)));
%         Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint([0 0 20 expInfo.windowSizePixels(2)],xcoordOccluders(loc),expInfo.center(2)));
%     end
% end
if expInfo.occluder
    for loc=1:length(xcoordOccluders)
        Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordOccluders(loc),ycoordOccluders(loc)))
    end
end

flipNb = 0; % keep track of the number of flips
stimStartTime = trialData.trialStartTime; % this is wrong but need a starting value for the while loop
seq = 0;seqObs=[];
% flip = trialData.testFlipFrame

% presentation stimulus
while ~KbCheck && t<conditionInfo.stimDuration+stimStartTime-ifi/2
    if strcmp(conditionInfo.label,'simult')
        for pos=1:totLoc % draw an oval in all locations
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordStim(pos)));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
        if flipNb == 1
            stimStartTime = t;
        end
        for pos=1:totLoc % draw a gray oval (= background) in all locations = no stim
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordStim(pos)));
        end
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2, 1);
        flipNb = flipNb+ 1;
    else % motion - for explanation, see below
        for pos=1:totLoc
            if ismember(seq, trialData.testFlipSeq) && strcmp(conditionInfo.label,'expected') % put back in grey for the next sequence
                for ss = 1:length(seqObsOld)
                    Screen('FillRect',expInfo.curWindow,gray,CenterRectOnPoint(rectObs,xcoordStim((seqObsOld(ss)-totLoc*(seq-1))),ycoordStim((seqObsOld(ss)-totLoc*(seq-1)))));
                end
            end
            Screen('FillOval', expInfo.curWindow, black, CenterRectOnPoint(rectCircle,xcoordStim(pos+1),ycoordStim(pos+1)));
            Screen('FillOval', expInfo.curWindow, gray, CenterRectOnPoint(rectCircle,xcoordStim(pos),ycoordStim(pos)));
            if ismember(seq, trialData.testFlipSeq) && strcmp(conditionInfo.label,'expected')
                seqObs = trialData.testFlipFrame(find(trialData.testFlipFrame>totLoc*seq & trialData.testFlipFrame < totLoc*(seq+1)))+1;
                for ss = 1:length(seqObs)
                    Screen('FillRect',expInfo.curWindow,black,CenterRectOnPoint(rectObs,xcoordStim((seqObs(ss)-totLoc*seq)),ycoordStim((seqObs(ss)-totLoc*seq))));
                end
            end
            if ismember(flipNb,trialData.testFlipFrame-1) && strcmp(conditionInfo.label,'unexpected')
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

