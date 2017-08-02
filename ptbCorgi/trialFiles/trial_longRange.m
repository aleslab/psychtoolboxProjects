function [trialData] = trial_longRange(expInfo, conditionInfo)
% give feedback for correct/incorrect answer?
% if a key is pressed during a trial, it stops the trial and becomes
% invalid
% if the escape key is pressed then the experiment is aborted

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'starttrial',true); 
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
preStimCycles = ceil(conditionInfo.preStimDuration * conditionInfo.stimTagFreq);
stimCycles = conditionInfo.stimDuration * conditionInfo.stimTagFreq ;
nbTotalCycles = preStimCycles*2 + stimCycles;
durationPerStim = nbFramesPerStim * 1/expInfo.monRefresh;
trialDuration = nbTotalCycles*2 * durationPerStim;
totStimPresented = (expInfo.monRefresh/nbFramesPerStim) * trialDuration; 

trialData.nbFramesPerStim = nbFramesPerStim;
trialData.nbTotalCycles = nbTotalCycles;
trialData.durationPerStim = durationPerStim;
trialData.trialDuration = trialDuration;
trialData.preStimDuration = preStimCycles * durationPerStim * 2; % *2 since 2 stim in 1 cycle




if expInfo.useBitsSharp
%     oddTrigger = expInfo.triggerInfo.ssvepOddstep;
    f1Trigger = expInfo.triggerInfo.ssvepTagF1;
else 
%     oddTrigger = 4;
    f1Trigger = 1;
end
abortExpTrigger = 99;
invalidTrialTrigger = 98; % miss frame
endStimTrigger = 10;

%%% parameters for the task
trialData.dims = randi((conditionInfo.maxDim+1),1)-1; % number of dims for this trial (can be 0)
% determine which stim is gray, 2 dims should not follow each other on the
% same stimulus
if conditionInfo.motion
    trialData.stimDim = randsample(1:3:(totStimPresented),trialData.dims);
else % if no motion then it has to be when the stim is on (only odd numbers) + avoid successive dims
    trialData.stimDim = randsample(1:4:(totStimPresented),trialData.dims);
end
% trialData.dims = 4;
% trialData.stimDim = [7 10 16 19];

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

% presentation stimulus
for cycleNb = 1 : nbTotalCycles
    % check if key is pressed in case needs to quit
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        trialData.validTrial = false;
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;
            ptbCorgiSendTrigger(expInfo,'raw',1,abortExpTrigger); % abort experiment trigger
        elseif keyCode(KbName('space'))
            trialData.validTrial = false;
            Screen('DrawText', expInfo.curWindow, 'Taking a break', 0, expInfo.center(2), [0 0 0]);
            Screen('DrawText', expInfo.curWindow, 'Press c to continue', 0, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
            Screen('Flip',expInfo.curWindow);
            pressSpace = 1;
            while pressSpace
                [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
                    if keyCode(KbName('c'))
                        pressSpace = 0;
                    end
            end
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
        end
        break;
    end
    if conditionInfo.motion == 1 % in motion (condition 1, 5, 9)
        % 2 stim presented % if strcmp(conditionInfo.sideStim,'both')
        %%% first stimulus
        % check if the stim is dim
        if ismember(nbStimPresented,trialData.stimDim)
            colStim = dimColour;  % triggerCode = oddTrigger;
        else
            colStim = black;  % triggerCode = f1Trigger;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
%         % for the photodiode
%         Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]);
        ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2 ); % or + ifi/2??
        if nbStimPresented == 1
            stimStartTime = t;
        end
%         t-prevStim
        % check timing (stimulus should be presented between supposed
        % duration +/- 1/2 frame)
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
            break;
        end
        nbStimPresented = nbStimPresented + 1;
        %%% second stimulus
        % check if the stim is dim
        if ismember(nbStimPresented,trialData.stimDim)
            colStim = dimColour; % triggerCode = oddTrigger;
        else
            colStim = black; % triggerCode = 0;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
%         % for the photodiode
%         Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]);
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2 );
%         t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
            break;
        end
        %%% SWEEP CONDITION 9
        if cycleNb > preStimCycles && cycleNb< nbTotalCycles-preStimCycles
            if strcmp(conditionInfo.label,'sweep') && mod(cycleNb-preStimCycles,5)==0
                xcoord = xcoord + movingStep;
            end
        end
        nbStimPresented = nbStimPresented + 1;
    else
        if strcmp(conditionInfo.sideStim,'both')  % simultaneous condition (4,8)
            %%% stim ON
            % check if the stim is dim
            if ismember(nbStimPresented,trialData.stimDim)
                colStim = Shuffle([dimColour,black]); % triggerCode = oddTrigger;
            else
                colStim = [black black]; % triggerCode = f1Trigger;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim(1),CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            Screen('FillRect', expInfo.curWindow, colStim(2),CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
        else % only one stim (left or right), conditions 2,3,6,7
            %%% stim ON
            % check if the stim is dim
            if ismember(nbStimPresented,trialData.stimDim)
                colStim = dimColour; % triggerCode = oddTrigger;
            else
                colStim = black; % triggerCode = f1Trigger;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,xcoordSingle,ycoord));
        end
        ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger); 
        prevStim = t;
%         % for the photodiode
%         Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]);
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2);
        if nbStimPresented == 1
            stimStartTime = t;
        end
%         t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
            break;
        end
        nbStimPresented = nbStimPresented+ 1;
        %%% stim OFF
        drawFixation(expInfo, expInfo.fixationInfo);
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
%         % for the photodiode
%         Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]);   
        t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2);
%         t-prevStim
        if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
            break;
        end
        nbStimPresented = nbStimPresented+ 1;
    end
end

drawFixation(expInfo, expInfo.fixationInfo);
ptbCorgiSendTrigger(expInfo,'raw',0,endStimTrigger); 
prevStim = t;
t = Screen('Flip', expInfo.curWindow, t + nbFramesPerStim * ifi - ifi/2);
trialData.stimEndTime = t;
% t-prevStim
if t-prevStim > durationPerStim + ifi/2 || t-prevStim < durationPerStim - ifi/2
    trialData.validTrial = false;
    ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
end

trialData.stimStartTime = stimStartTime;

% Find the key values (not the same in PC and MAC) for the response loop
for keyVal=0:conditionInfo.maxDim
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end

if trialData.validTrial
    if nbStimPresented-1 ~= totStimPresented % not very useful to check: very unlickely that it is not the case
        trialData.validTrial = false;
    else
        % response screen
        Screen('DrawText', expInfo.curWindow, 'Number of dim objects?', 0, expInfo.center(2), [0 0 0]);
        Screen('DrawText', expInfo.curWindow, ['(0-' num2str(conditionInfo.maxDim) ')'], 0, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
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
    ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial 
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.stimDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationReal = trialData.trialEndTime - trialData.trialStartTime ;

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'endtrial',true); 
end

end

