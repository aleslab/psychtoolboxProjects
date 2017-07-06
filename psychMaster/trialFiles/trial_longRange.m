function [trialData] = trial_longRange(expInfo, conditionInfo)
% give feedback for correct/incorrect answer?
% if a key is pressed during a trial, it stops the trial and becomes
% invalid
% if the escape key is pressed then the experiment is aborted

% trigger to abort experiment (press escape) = 99
% trigger to abort trial (miss frame) = 98

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'raw',true,triggerInfo.startTrial); 
end
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;

black = BlackIndex(expInfo.curWindow);
dimColour = 0.3;

%%% VEP parameters
nbFramesPerStim = expInfo.monRefresh/conditionInfo.stimTagFreq/2; % at 85Hz refresh = 5 img/sec and 2.5Hz per side
nbTotalCycles = conditionInfo.stimDuration * conditionInfo.stimTagFreq;
totStimPresented = (expInfo.monRefresh/nbFramesPerStim) * conditionInfo.stimDuration; % not useful to check anymore
durationPerStim = nbFramesPerStim * 1/expInfo.monRefresh;

trialData.nbFramesPerStim = nbFramesPerStim;
trialData.nbTotalCycles = nbTotalCycles;
trialData.durationPerStim = durationPerStim;

if expInfo.useBitsSharp
    oddTrigger = triggerInfo.ssvepOddstep;
    f1Trigger = triggerInfo.ssvepTagF1;
else 
    oddTrigger = 4;
    f1Trigger = 1;
end

%%% parameters for the task
trialData.dims = randi((conditionInfo.maxDim+1),1)-1; % number of dims for this trial (can be 0)
% determine which stim is gray, 2 dims should not follow each other on the
% same stimulus
if conditionInfo.motion
    trialData.stimDim = randsample(1:3:(totStimPresented),trialData.dims);
else % if no motion then it has to be when the stim is on (only odd numbers) + avoid successive dims
    trialData.stimDim = randsample(1:4:(totStimPresented),trialData.dims);
end

%%% stim presentation parameters
rectCircle = conditionInfo.stimSize*expInfo.ppd;
ifi = expInfo.ifi;
ycoord = expInfo.center(2)/2;
xcoord = conditionInfo.xloc(1)*expInfo.ppd; % to be substracted or added
movingStep = conditionInfo.movingStep*expInfo.ppd;

if strcmp(conditionInfo.sideStim,'left')
    xcoordSingle = expInfo.center(1)-xcoord;
elseif strcmp(conditionInfo.sideStim,'right')
    xcoordSingle = expInfo.center(1)+xcoord;
end

nbStimPresented = 1; % keep count of the nb of stimulus (for the dim). 1 cycle is 2 stim
durationPerStim + ifi/2
durationPerStim - ifi/2


% presentation stimulus
for cycleNb = 1 : nbTotalCycles
    % check if key is pressed in case needs to quit
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        trialData.validTrial = false;
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;
        end
        ptbCorgiSendTrigger(expInfo,'raw',1,99); % abort experiment trigger
        break;
    end
    if conditionInfo.motion == 1 % in motion (condition 1, 5, 9)
        % 2 stim presented % if strcmp(conditionInfo.sideStim,'both')
        %%% first stimulus
        % check if the stim is dim
        if ismember(nbStimPresented,trialData.stimDim)
            colStim = dimColour; triggerCode = oddTrigger;
        else
            colStim = black; triggerCode = f1Trigger;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
        ptbCorgiSendTrigger(expInfo,'raw',0,triggerCode);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2 ); % or + ifi/2??
        if nbStimPresented == 1
            stimStartTime = t;
        end
        t-prevStim
        % check timing (stimulus should be presented between supposed
        % duration +/- 1/2 frame)
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,98); % abort trial trigger
%             break;
        end
        nbStimPresented = nbStimPresented + 1;
        %%% second stimulus
        % check if the stim is dim
        if ismember(nbStimPresented,trialData.stimDim)
            colStim = dimColour;triggerCode = oddTrigger;
        else
            colStim = black;triggerCode = f1Trigger;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2 );
        t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,98); % abort trial trigger
%             break;
        end
        %%% SWEEP CONDITION 9
        if strcmp(conditionInfo.label,'sweep')
            xcoord = xcoord + movingStep;
        end
        nbStimPresented = nbStimPresented + 1;
    else
        if strcmp(conditionInfo.sideStim,'both')  % simultaneous condition (4,8)
            %%% stim ON
            % check if the stim is dim
            if ismember(nbStimPresented,trialData.stimDim)
                colStim = Shuffle([dimColour,black]); triggerCode = oddTrigger;
            else
                colStim = [black black]; triggerCode = f1Trigger;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim(1),CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            Screen('FillRect', expInfo.curWindow, colStim(2),CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
        else % only one stim (left or right), conditions 2,3,6,7
            %%% stim ON
            % check if the stim is dim
            if ismember(nbStimPresented,trialData.stimDim)
                colStim = dimColour; triggerCode = oddTrigger;
            else
                colStim = black; triggerCode = f1Trigger;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,xcoordSingle,ycoord));
        end
        ptbCorgiSendTrigger(expInfo,'raw',0,triggerCode); 
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi );
        if nbStimPresented == 1
            stimStartTime = t;
        end
        t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,98); % abort trial trigger
%             break;
        end
        nbStimPresented = nbStimPresented+ 1;
        %%% stim OFF
        drawFixation(expInfo, expInfo.fixationInfo);
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi );
        t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,98); % abort trial trigger
%             break;
        end
        nbStimPresented = nbStimPresented+ 1;
    end
end

drawFixation(expInfo, expInfo.fixationInfo);
ptbCorgiSendTrigger(expInfo,'clear',0);
prevStim = t;
t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi );
trialData.stimEndTime = t;
t-prevStim
if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
    trialData.validTrial = false;
    ptbCorgiSendTrigger(expInfo,'raw',1,98); % abort trial trigger
end

trialData.stimStartTime = stimStartTime;

% Find the key values (not the same in PC and MAC) for the response loop
for keyVal=0:conditionInfo.maxDim
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end
trialData.validTrial = true;
if trialData.validTrial
    if nbStimPresented-1 ~= totStimPresented % not very useful to check: very unlickely that it is not the case
        trialData.validTrial = false;
    else
        % response screen
        Screen('DrawText', expInfo.curWindow, 'Nb of dims?', expInfo.center(1), expInfo.center(2), [0 0 0]);
        Screen('DrawText', expInfo.curWindow, ['(0-' num2str(conditionInfo.maxDim) ')'], expInfo.center(1), expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
        trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
        % check for key press
        while trialData.response==999 && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
            [keyDown, secs, keyCode] = KbCheck;
            if keyDown
                if find(keyCode)>=min(vectKeyVal) && find(keyCode)<=max(vectKeyVal)
                    trialData.response = str2num(KbName(keyCode));
                    trialData.rt = secs - trialData.respScreenTime;
                    if trialData.response == trialData.dims
                        trialData.correct = 1;
                    else
                        trialData.correct = 0;
                    end
                else
                    if keyCode(KbName('ESCAPE'))
                        trialData.abortNow   = true;
                    end
                    trialData.validTrial = false;break;
                end
            end
        end
        FlushEvents('keyDown');
    end
end

if trialData.response==999 % no response
    trialData.validTrial = false;
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.stimDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationReal = trialData.trialEndTime - trialData.trialStartTime ;


end

