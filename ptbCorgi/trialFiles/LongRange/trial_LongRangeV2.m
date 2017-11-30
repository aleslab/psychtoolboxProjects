function [trialData] = trial_LongRangeV2(expInfo, conditionInfo)
% if the escape key is pressed then the experiment is aborted
% press space to pause the experiment

stimStartTime = 0;

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
dimColour = 0.5;

%%% VEP parameters
cycleDuration = 1/conditionInfo.stimTagFreq; % 1 cycle is 2 stimulus (left, right and then back to left)
halfCycleDuration = cycleDuration/2;
monitorPeriodSecs = 1/expInfo.monRefresh;
framesPerHalfCycle = halfCycleDuration/monitorPeriodSecs;
framesPerStim = round((halfCycleDuration - conditionInfo.isi)/monitorPeriodSecs);
isi = (framesPerHalfCycle - framesPerStim) * monitorPeriodSecs;
stimDuration = framesPerStim * monitorPeriodSecs;

% compute the nb of cycles before and after stim presentation
% and compute the trial duration depending on that
preStimCycles = ceil(conditionInfo.preStimDuration * conditionInfo.stimTagFreq);
nbTotalCycles = preStimCycles*2 + conditionInfo.trialDuration * conditionInfo.stimTagFreq;
trialDuration = nbTotalCycles * cycleDuration;
totStimPresented = trialDuration / halfCycleDuration;

% save it in the data output structure
trialData.framesPerHalfCycle = framesPerHalfCycle;
trialData.nbFramesPerStim = framesPerStim;
trialData.nbTotalCycles = nbTotalCycles;
trialData.durationPerStim = framesPerStim * monitorPeriodSecs;
trialData.durationISI = isi;
trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;
trialData.preStimDuration = preStimCycles * stimDuration * 2; % *2 since 2 stim in 1 cycle 
trialData.totStimPresented = totStimPresented;

if expInfo.useBitsSharp
    %     oddTrigger = expInfo.triggerInfo.ssvepOddstep;
    f1Trigger = expInfo.triggerInfo.ssvepTagF1;
    checkTiming = 1;
else
    %     oddTrigger = 4;
    f1Trigger = 1;
    checkTiming = 0; % timing of the nb of frames only checked for the "real" experiment using bitsharp
end
abortExpTrigger = 99;
invalidTrialTrigger = 98; % miss frame
endStimTrigger = 10;

%%% parameters for the task
trialData.nbDots = randi((conditionInfo.maxDots+1),1)-1; % number of dots for this trial (can be 0)
% determine when the dot appears, restrict it to avoid successive dots
if conditionInfo.motion
    trialData.dots = randsample(1:3:(totStimPresented),trialData.nbDots);
else % if no motion then it has to be when the stim is on (only odd numbers)
    trialData.dots = randsample(1:4:(totStimPresented),trialData.nbDots);
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

dotSize = conditionInfo.dotSize*expInfo.ppd;
% the dot is not presented within 0.5 deg of the border of the rectangle stimulus
maxYdot = ycoord + (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;
minYdot = ycoord - (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;

nbStimPresented = 1; % keep count of the nb of stimulus (to know when to present the dot). 1 cycle is 2 stim

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
    if conditionInfo.motion == 1 % in motion 
        %%% first stimulus ON
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
        if ismember(nbStimPresented,trialData.dots) % check for stim to detect
            yDot = (maxYdot-minYdot)*rand(1)+minYdot;
            Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,expInfo.center(1)-xcoord,yDot));
        end
        %         % for the photodiode
        %         Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]);
        
        ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + framesPerHalfCycle * ifi - ifi/2 ); % or + ifi/2??
        if nbStimPresented == 1
            stimStartTime = t;
        end
        %         t-prevStim
        
        %%% end 1st stimulus
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('Flip', expInfo.curWindow, t + framesPerStim * ifi - ifi/2 );
        
        % check timing (halfCycleDuration +/- 1/2 frame)
        if checkTiming
            if t-prevStim > halfCycleDuration + ifi/2 || t-prevStim < halfCycleDuration - ifi/2
                trialData.validTrial = false;
                ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
                break;
            end
        end
        nbStimPresented = nbStimPresented + 1;
        
        %%% second stimulus ON
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
        if ismember(nbStimPresented,trialData.dots) % check for stim to detect
            yDot = (maxYdot-minYdot)*rand(1)+minYdot;
            Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,expInfo.center(1)+xcoord,yDot));
        end
        %         % for the photodiode
        %         Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]);
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + framesPerHalfCycle * ifi - ifi/2 );
        
        %%% end 2nd stimulus
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('Flip', expInfo.curWindow, t + framesPerStim * ifi - ifi/2 );
        
        % check timing (halfCycleDuration +/- 1/2 frame)
        if checkTiming
            if t-prevStim > halfCycleDuration + ifi/2 || t-prevStim < halfCycleDuration - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
            break;
            end
        end
%         t-prevStim
        %%% SWEEP CONDITION 
        if cycleNb > preStimCycles && cycleNb< nbTotalCycles-preStimCycles
            if strcmp(conditionInfo.label,'sweep') && mod(cycleNb-preStimCycles,5)==0
                xcoord = xcoord + movingStep;
            end
        end
        nbStimPresented = nbStimPresented + 1;
    else % not in motion
        %%% 1st stimulus
        if strcmp(conditionInfo.sideStim,'both')  % simultaneous condition 
            %%% stim ON
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
            if ismember(nbStimPresented,trialData.dots) % check for stim to detect
                yDot = (maxYdot-minYdot)*rand(1)+minYdot;
                xDotp = Shuffle([expInfo.center(1)-xcoord expInfo.center(1)+xcoord]);
                Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xDotp(1),yDot));
            end
        else % only one stim (left or right)
            %%% stim ON
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,xcoordSingle,ycoord));
            if ismember(nbStimPresented,trialData.dots) % check for stim to detect
                yDot = (maxYdot-minYdot)*rand(1)+minYdot;
                Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xcoordSingle,yDot));
            end
        end
        ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
        prevStim = t;
        %         % for the photodiode
        %         Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]);
        t = Screen('Flip', expInfo.curWindow, t + framesPerHalfCycle * ifi - ifi/2);
        if nbStimPresented == 1
            stimStartTime = t;
        end
        %         t-prevStim

        %%% end 1st stimulus
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('Flip', expInfo.curWindow, t + framesPerStim * ifi - ifi/2 );
        
        if checkTiming
            if t-prevStim > halfCycleDuration + ifi/2 || t-prevStim < halfCycleDuration - ifi/2
                trialData.validTrial = false;
                ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
                break;
            end
        end
        nbStimPresented = nbStimPresented+ 1;
        
        %%% 2nd stimulus
        % present for half cycle condition, absent in full cycle condition
        drawFixation(expInfo, expInfo.fixationInfo);
        if strcmp(conditionInfo.cycle,'half')
            if strcmp(conditionInfo.sideStim,'both')  % simultaneous condition 
                drawFixation(expInfo, expInfo.fixationInfo);
                Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
                Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
                if ismember(nbStimPresented,trialData.dots) % check for stim to detect
                    yDot = (maxYdot-minYdot)*rand(1)+minYdot;
                    xDotp = Shuffle([expInfo.center(1)-xcoord expInfo.center(1)+xcoord]);
                    Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xDotp(1),yDot));
                end
            else % only one stim (left or right), conditions 
                drawFixation(expInfo, expInfo.fixationInfo);
                Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectCircle,xcoordSingle,ycoord));
                if ismember(nbStimPresented,trialData.dots) % check for stim to detect
                    yDot = (maxYdot-minYdot)*rand(1)+minYdot;
                    Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xcoordSingle,yDot));
                end
            end
        end
        ptbCorgiSendTrigger(expInfo,'clear',0);
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow, t + framesPerHalfCycle * ifi - ifi/2 );
        
        %%% end 2nd stimulus
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('Flip', expInfo.curWindow, t + framesPerStim * ifi - ifi/2 );
        
        if checkTiming
            if t-prevStim > halfCycleDuration + ifi/2 || t-prevStim < halfCycleDuration - ifi/2
                trialData.validTrial = false;
                ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
                break;
            end
        end
        nbStimPresented = nbStimPresented+ 1;

    end
end

% this is to send a last trigger
drawFixation(expInfo, expInfo.fixationInfo);
ptbCorgiSendTrigger(expInfo,'raw',0,endStimTrigger);
prevStim = t;
t = Screen('Flip', expInfo.curWindow, t + framesPerHalfCycle * ifi - ifi/2);
trialData.stimEndTime = t;
% t-prevStim
if checkTiming
    if t-prevStim > halfCycleDuration + ifi/2 || t-prevStim < halfCycleDuration - ifi/2
    trialData.validTrial = false;
    ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
    end
end

trialData.stimStartTime = stimStartTime;

% Find the key values (not the same in PC and MAC) for the response loop
for keyVal=0:conditionInfo.maxDots
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end

if trialData.validTrial
    if nbStimPresented-1 ~= totStimPresented % not very useful to check: very unlickely that it is not the case
        trialData.validTrial = false;
    else
        % response screen
        Screen('DrawText', expInfo.curWindow, 'Number of dots?', 0, expInfo.center(2), [0 0 0]);
        Screen('DrawText', expInfo.curWindow, ['(0-' num2str(conditionInfo.maxDots) ')'], 0, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
        trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
        % check for key press
        while trialData.response==999 && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
            [keyDown, secs, keyCode] = KbCheck;
            if keyDown
                if find(keyCode)>=min(vectKeyVal) && find(keyCode)<=max(vectKeyVal)
                    trialData.response = str2num(KbName(keyCode));
                    trialData.rt = secs - trialData.respScreenTime;
                    if trialData.response == trialData.nbDots
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

trialData.trialDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'endtrial',true);
end

end

