function [trialData] = trial_bestFreq(expInfo, conditionInfo)
% if the escape key is pressed then the experiment is aborted
% press space to pause the experiment

stimStartTime = 0;
black = BlackIndex(expInfo.curWindow);

listFreq = expInfo.listFreq;

drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(0.1);
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
ifi = expInfo.ifi;

if expInfo.useBitsSharp
    checkTiming = 1;
else
    checkTiming = 0; % timing of the nb of frames only checked for the "real" experiment using bitsharp
end



%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) + (conditionInfo.yloc * expInfo.ppd);
xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd);
eccMotion = xcoord + (conditionInfo.locMotion * expInfo.ppd);

freqNb = 1;
cycleNb =1;
pressSpace = 1;
while pressSpace
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;
            trialData.validTrial = false;
            break;
        elseif keyCode(KbName('space'))
            pressSpace = 0;
            break;
        elseif keyCode(KbName('1'))
            freqNb = 1;
        elseif keyCode(KbName('2'))
            freqNb = 2;
        elseif keyCode(KbName('3'))
            freqNb = 3;
        elseif keyCode(KbName('4'))
            freqNb = 4;
        end
    end
    
    %%% VEP parameters
    chosenFreq = listFreq(freqNb);
    framesPerCycle = 1/chosenFreq * round(expInfo.monRefresh);
    cycleDuration = 1/chosenFreq;
    framesOn = conditionInfo.dutyCycle * framesPerCycle;
    framesOff = framesPerCycle - framesOn;
    
    Screen('DrawText', expInfo.curWindow, num2str(freqNb), 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
    %%% stim ON
    drawFixation(expInfo, expInfo.fixationInfo);
    if mod(cycleNb,2)==1 % in motion
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,eccMotion,ycoord));
        cycleNb =2;
    else
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,xcoord,ycoord));
        cycleNb =1;
    end
    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;trialData.validTrial = false;
        elseif keyCode(KbName('space'))
            pressSpace = 0;
            break;
        elseif keyCode(KbName('1'))
            freqNb = 1;
        elseif keyCode(KbName('2'))
            freqNb = 2;
        elseif keyCode(KbName('3'))
            freqNb = 3;
        elseif keyCode(KbName('4'))
            freqNb = 4;
        end
    end
    
    %%% stim OFF
    %Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    Screen('DrawText', expInfo.curWindow, num2str(freqNb), 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
    drawFixation(expInfo, expInfo.fixationInfo);
    t = Screen('Flip', expInfo.curWindow, t + framesOn * ifi - ifi/2 );

end
FlushEvents('keyDown');

% save parameters in the data output structure
monitorPeriodSecs = 1/round(expInfo.monRefresh);
trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = monitorPeriodSecs * framesOn;
trialData.timeStimOff = monitorPeriodSecs * framesOff;
trialData.cycleDuration = cycleDuration;


drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;
trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;


end

