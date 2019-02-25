function [trialData] = trial_standardDist(expInfo, conditionInfo)


stimStartTime = 0;
if conditionInfo.stim == 2
    stimCol = 0.47; % 0.55 = 10% contrast, 0.47 = 6% (47 is towards black)
else
    stimCol = BlackIndex(expInfo.curWindow);
end
refCol = BlackIndex(expInfo.curWindow);

drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(0.1);
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;
ifi = expInfo.ifi;

if expInfo.useBitsSharp
    checkTiming = 1;
else
    checkTiming = 0; % timing of the nb of frames only checked for the "real" experiment using bitsharp
end

%%% VEP parameters
framesPerCycle = 1/conditionInfo.stimTagFreq * round(expInfo.monRefresh);
cycleDuration = 1/conditionInfo.stimTagFreq;
monitorPeriodSecs = 1/round(expInfo.monRefresh);

% framesPerCycle = cycleDuration / monitorPeriodSecs;
framesOn = conditionInfo.dutyCycle * framesPerCycle;
framesOff = framesPerCycle - framesOn;

timeStimOn = monitorPeriodSecs * framesOn;
timeStimOff = monitorPeriodSecs * framesOff;

nbTotalCycles = ceil(conditionInfo.trialDuration * conditionInfo.stimTagFreq);
trialDuration = nbTotalCycles * cycleDuration; 

% save it in the data output structure
trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = timeStimOn;
trialData.timeStimOff = timeStimOff;
trialData.nbTotalCycles = nbTotalCycles;
trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;


%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); % - above
xcoord = [expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd) ...
    expInfo.center(1) + ((conditionInfo.xloc+conditionInfo.xMotion) * expInfo.ppd)]; % + right
xcoordRef = expInfo.center(1) + (conditionInfo.xlocRef * expInfo.ppd);


% start trial
for cycleNb = 1 : nbTotalCycles
    % check if key is pressed in case needs to quit
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        trialData.validTrial = false;
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;
        end
        break;
    end

    %%% stim ON
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,xcoord(mod(cycleNb,2)+1),ycoord));
    Screen('FillRect', expInfo.curWindow, refCol,CenterRectOnPoint(rectStim,xcoordRef(mod(cycleNb,2)+1),ycoord));
    
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    firstON = t;
    if cycleNb == 1
        stimStartTime = t;
    end
    
    %%% stim OFF
    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    drawFixation(expInfo, expInfo.fixationInfo);
    t = Screen('Flip', expInfo.curWindow, firstON + framesOn * ifi - ifi/2 );
    if checkTiming
        if t-firstON > timeStimOn + ifi/2 || t-firstON < timeStimOn - ifi/2
            trialData.validTrial = false;
            break;
        end
    end
    
        
end

% this is to send a last trigger
drawFixation(expInfo, expInfo.fixationInfo);
prevStim = t;
t = Screen('Flip', expInfo.curWindow, t + framesPerCycle * ifi - ifi/2);
trialData.stimEndTime = t;
% t-prevStim
if checkTiming
    if t-prevStim > cycleDuration + ifi/2 || t-prevStim < cycleDuration - ifi/2
    trialData.validTrial = false;
    end
end

trialData.stimStartTime = stimStartTime;


if trialData.validTrial
    % response screen
    Screen('DrawText', expInfo.curWindow, 'which stimulus travelled farther?', 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'left arrow', 0, expInfo.center(2), [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'right arrow', 0, expInfo.center(2)+expInfo.center(2)/8, [0 0 0]);
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
        [keyDown, secs, keyCode] = KbCheck;
        if keyDown
            if length(find(keyCode)) == 1 % only one key pressed
                    if strcmp(KbName(keyCode),'LeftArrow')
                        trialData.response = 'left';
                        trialData.rt = secs - trialData.respScreenTime;
                    elseif strcmp(KbName(keyCode),'RightArrow')
                        trialData.response = 'right';
                        trialData.rt = secs - trialData.respScreenTime;
                    elseif keyCode(KbName('ESCAPE'))
                        trialData.abortNow   = true;
                        trialData.validTrial = false;
                        trialData.response = 99;
                    end
            end
        end
    end
    FlushEvents('keyDown');
end

if trialData.response==999 % no response
    trialData.validTrial = false;
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.trialDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;


end

