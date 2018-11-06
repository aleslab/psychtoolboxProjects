function [trialData] = trial_ternus_multipleTag(expInfo, conditionInfo)

expInfo.monRefresh = 85; %% force to be 85Hz so that the fram counting works


stimStartTime = 0;
stimCol = BlackIndex(expInfo.curWindow);

drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(0.1);
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);

trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;

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
trialDuration = nbTotalCycles * cycleDuration; % =11.67060200
nbTotalFrames = framesPerCycle * nbTotalCycles;

%%% peripheral stimulus
framesPerCyclePeri = 1/conditionInfo.periFreq * round(expInfo.monRefresh);
cycleDurationPeri = 1/conditionInfo.periFreq;
framesPeriOn = conditionInfo.dutyCycle * framesPerCyclePeri;
framesPeriOff = framesPerCyclePeri - framesPeriOn;
timeStimOnPeri = monitorPeriodSecs * framesPeriOn;
timeStimOffPeri = monitorPeriodSecs * framesPeriOff;
nbTotalCyclesPeri = ceil(conditionInfo.trialDuration * conditionInfo.periFreq);
nbTotalFramesPeri = framesPerCyclePeri * nbTotalCyclesPeri;

% save it in the data output structure
trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = timeStimOn;
trialData.timeStimOff = timeStimOff;
trialData.nbTotalCycles = nbTotalCycles;
trialData.nbTotalFrames = nbTotalFrames;
trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;

trialData.framesPerCyclePeri = framesPerCyclePeri;
trialData.cycleDurationPeri = cycleDurationPeri;
trialData.framesPeriOn = framesPeriOn;
trialData.framesPeriOff = framesPeriOff;
trialData.timeStimOnPeri = timeStimOnPeri;
trialData.timeStimOffPeri = timeStimOffPeri;
trialData.nbTotalCyclesPeri = nbTotalCyclesPeri;
trialData.nbTotalFramesPeri = nbTotalFramesPeri;

%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); % - above
xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd); % + right
nbStim = conditionInfo.nbStim;
intX = conditionInfo.intX * expInfo.ppd;
% loc1 = conditionInfo.loc1 * expInfo.ppd;
% loc2 = conditionInfo.loc2 * expInfo.ppd;

% % horizontal bar
% horizBar = conditionInfo.horizBar*expInfo.ppd;
% yBarTop = ycoord - conditionInfo.stimSize(4)/2*expInfo.ppd;
% yBarBottom = ycoord + conditionInfo.stimSize(4)/2*expInfo.ppd;
extraCol = [0 1 0];
% if conditionInfo.stimType == 1
%     extraCol = stimCol;
% else
%     extraCol = [0 1 0];
% end

curCycle = 1;curCyclePeri=1;
% start trial
for curFrame = 1 : nbTotalFrames    
    % check which cycle it is
    if curFrame == framesPerCycle+1 + (curCycle-1)*framesPerCycle
        curCycle = curCycle+1;
    end
    if curFrame == framesPerCyclePeri+1 + (curCyclePeri-1)*framesPerCyclePeri
        curCyclePeri = curCyclePeri+1;
    end
    % check if key is pressed in case needs to quit
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        trialData.validTrial = false;
        if keyCode(KbName('escape'))
            trialData.abortNow = true;
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
        end
        break;1
    end
    
    % CENTRAL STIM
    if curFrame == framesPerCycle * (curCycle - 1) +1 %%% central stim ON
        centerOn = 1; 
    end
    if curFrame == (framesOn + 1) + framesPerCycle * (curCycle - 1) %%% central stim OFF
        centerOn = 0; 
    end
    
    % PERIPHERAL STIM (different freq + motion)
    if curFrame == framesPerCyclePeri * (curCyclePeri - 1) +1 %%% stim ON
        periOn = 1; 
    end
    if curFrame == (framesPeriOn + 1) + framesPerCyclePeri * (curCyclePeri - 1) %%% stim OFF
        periOn = 0; 
    end

    
    %%% now flip if needed 
%     if doFlip == 1
        drawFixation(expInfo, expInfo.fixationInfo);
        if centerOn
            for num=1:nbStim
                Screen('FillOval', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,xcoord+(num-1)*intX,ycoord));
            end
        end
        if periOn
            if mod(curCyclePeri,2)==0
                Screen('FillOval', expInfo.curWindow, extraCol,CenterRectOnPoint(rectStim,xcoord-intX,ycoord));
                Screen('FillOval', expInfo.curWindow, extraCol,CenterRectOnPoint(rectStim,xcoord-2*intX,ycoord));
            else
                Screen('FillOval', expInfo.curWindow, extraCol,CenterRectOnPoint(rectStim,xcoord+nbStim*intX,ycoord));
                Screen('FillOval', expInfo.curWindow, extraCol,CenterRectOnPoint(rectStim,xcoord+(1+nbStim)*intX,ycoord));
            end
        end
        prevStim = t;
        t = Screen('Flip', expInfo.curWindow);
        if checkTiming
            if t-prevStim > ifi/2
                trialData.validTrial = false;
            end
        end
            
%     end
        
end

% this is to send a last trigger
drawFixation(expInfo, expInfo.fixationInfo);
prevStim = t;
t = Screen('Flip', expInfo.curWindow);
trialData.stimEndTime = t;

trialData.stimStartTime = stimStartTime;

% Find the key values (not the same in PC and MAC) for the response loop
for keyVal=0:3
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end

if trialData.validTrial
    % response screen
    Screen('DrawText', expInfo.curWindow, 'Did the stimulus move horizontally?', 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, '0. definitely not ', 0, expInfo.center(2), [0 0 0]);
    Screen('DrawText', expInfo.curWindow, '1. probably not', 0, expInfo.center(2)+expInfo.center(2)/8, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, '2. probably yes', 0, expInfo.center(2)+expInfo.center(2)*2/8, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, '3. definitely yes', 0, expInfo.center(2)+expInfo.center(2)*3/8, [0 0 0]);
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
        [keyDown, secs, keyCode] = KbCheck;
        if keyDown
            if find(keyCode)>=min(vectKeyVal) && find(keyCode)<=max(vectKeyVal)
                trialData.response = str2num(KbName(keyCode));
                trialData.rt = secs - trialData.respScreenTime;
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
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.trialDurationReal = trialData.stimEndTime - trialData.stimStartTime ;
trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;


end

