function [trialData] = trial_LRshortDC(expInfo, conditionInfo)
% if the escape key is pressed then the experiment is aborted
% press space to pause the experiment
% start with the stimulus on the right in the motion condition

stimStartTime = 0;
black = BlackIndex(expInfo.curWindow);
dimColour = 0.4;

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'starttrial',true);
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
Screen('FillRect', expInfo.curWindow, black,[0 0 1280 3]);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;
ifi = expInfo.ifi;


%%% VEP parameters
framesPerCycle = 1/conditionInfo.stimTagFreq * round(expInfo.monRefresh);
cycleDuration = 1/conditionInfo.stimTagFreq;
monitorPeriodSecs = 1/round(expInfo.monRefresh);

% framesPerCycle = cycleDuration / monitorPeriodSecs;
framesOn = conditionInfo.framesOn;
framesOff = framesPerCycle - framesOn;

timeStimOn = monitorPeriodSecs * framesOn;
timeStimOff = monitorPeriodSecs * framesOff;


% compute the nb of cycles before and after stim presentation
% and compute the trial duration depending on that
% preStimCycles = ceil(conditionInfo.preStimDuration / cycleDuration);
preStimCycles = ceil(conditionInfo.preStimDuration * conditionInfo.stimTagFreq);
nbTotalCycles = ceil(preStimCycles*2 + conditionInfo.trialDuration * conditionInfo.stimTagFreq);
trialDuration = nbTotalCycles * cycleDuration; % =11.67060200

% save it in the data output structure
trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = timeStimOn;
trialData.timeStimOff = timeStimOff;
trialData.nbTotalCycles = nbTotalCycles;
trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;

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
% (not presented during off or the next on = every 4 cycles) and
% do not include pre-post 'baseline'
trialData.dots = randsample(4:4:nbTotalCycles-3,trialData.nbDots);


%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); % - above
switch conditionInfo.sideStim
    case 'left'
        xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd); 
    case 'right'
        xcoord = expInfo.center(1) + ((conditionInfo.xloc+conditionInfo.xMotion) * expInfo.ppd); 
    case 'both'
        xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd);
end
eccMotion = xcoord + (conditionInfo.xMotion * expInfo.ppd); 
dotSize = conditionInfo.dotSize*expInfo.ppd;
% the dot is not presented within 0.5 deg of the border of the rectangle stimulus
maxYdot = ycoord + (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;
minYdot = ycoord - (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;



% start trial
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

    %%% stim ON
    drawFixation(expInfo, expInfo.fixationInfo);
    if conditionInfo.motion == 1 && mod(cycleNb,2)==1 % in motion
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,eccMotion,ycoord));
        if ismember(cycleNb,trialData.dots) % check for stim to detect
            yDot = (maxYdot-minYdot)*rand(1)+minYdot;
            Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,eccMotion,yDot));
        end
    elseif conditionInfo.simult == 1
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,xcoord,ycoord));
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,eccMotion,ycoord));
        xDot = Shuffle([xcoord eccMotion]);
        if ismember(cycleNb,trialData.dots) % check for stim to detect
            yDot = (maxYdot-minYdot)*rand(1)+minYdot;
            Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xDot(1),yDot));
        end        
    else
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,xcoord,ycoord));
        if ismember(cycleNb,trialData.dots) % check for stim to detect
            yDot = (maxYdot-minYdot)*rand(1)+minYdot;
            Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xcoord,yDot));
        end        
    end
    ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    Screen('FillRect', expInfo.curWindow, black,[0 0 1280 3]);
    if cycleNb == 1
        stimStartTime = t;
    end
    
    %%% stim OFF
    %Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    drawFixation(expInfo, expInfo.fixationInfo);
    ptbCorgiSendTrigger(expInfo,'clear',0);
    t = Screen('Flip', expInfo.curWindow, t + framesOn * ifi - ifi/2 );
    Screen('FillRect', expInfo.curWindow, black,[0 0 1280 3]);
        
    if checkTiming
        if t-prevStim > cycleDuration + ifi/2 || t-prevStim < cycleDuration - ifi/2
            trialData.validTrial = false;
            ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
            break;
        end
    end
        
end

% this is to send a last trigger
drawFixation(expInfo, expInfo.fixationInfo);
ptbCorgiSendTrigger(expInfo,'raw',0,endStimTrigger);
prevStim = t;
t = Screen('Flip', expInfo.curWindow, t + framesPerCycle * ifi - ifi/2);
Screen('FillRect', expInfo.curWindow, black,[0 0 1280 3]);
trialData.stimEndTime = t;
% t-prevStim
if checkTiming
    if t-prevStim > cycleDuration + ifi/2 || t-prevStim < cycleDuration - ifi/2
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
    % response screen
    Screen('DrawText', expInfo.curWindow, 'Number of dots?', 0, expInfo.center(2), [0 0 0]);
    Screen('DrawText', expInfo.curWindow, ['(0-' num2str(conditionInfo.maxDots) ')'], 0, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
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

if trialData.response==999 % no response
    trialData.validTrial = false;
    ptbCorgiSendTrigger(expInfo,'raw',1,invalidTrialTrigger); % abort trial
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
Screen('FillRect', expInfo.curWindow, black,[0 0 1280 3]);
trialData.trialEndTime = t;

trialData.trialDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;

if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'endtrial',true);
end

end

