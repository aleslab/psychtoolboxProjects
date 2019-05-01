function [trialData] = trial_SeqContext(expInfo, conditionInfo)
% if the escape key is pressed then the experiment is aborted
% press space to pause the experiment

stimStartTime = 0;
black = BlackIndex(expInfo.curWindow);
dimColour = 0.5;

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

nbTotalSeq = conditionInfo.nbSeq;
trialDuration = nbTotalSeq * cycleDuration * length(conditionInfo.seq);

% save it in the data output structure
trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = timeStimOn;
trialData.timeStimOff = timeStimOff;
trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;
    
%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) + (conditionInfo.yloc * expInfo.ppd); % 1 location
xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd); % 4 locations

% the dot is not presented within 0.5 deg of the border of the rectangle stimulus
dotSize = conditionInfo.dotSize*expInfo.ppd;
maxYdot = ycoord + (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;
minYdot = ycoord - (conditionInfo.stimSize(4)-1)/2 * expInfo.ppd;

% stim sequence
if conditionInfo.seq == 9 % random 
    fullSeq = Shuffle(repmat(1:5,1,nbTotalSeq));
    for ss=1:length(fullSeq) 
        if fullSeq(ss) == 4
            fullSeq(ss+1) = 0;
            fullSeq(ss+2) = 0;
        end
    end
else 
    fullSeq = repmat(conditionInfo.seq,1,nbTotalSeq);
end

indexOn = find(fullSeq>0);
nbDots = randi(4)-1; % between 0 and 3 dots
indexOn = Shuffle(indexOn);
if nbDots == 0
    timeDots = [];
else
    timeDots = indexOn(1:nbDots);
end
trialData.timeDots = timeDots;
trialData.nbDots = nbDots;
trialData.fullSeq = fullSeq;


% start trial
for locNb = 1:length(fullSeq)
    % check if key is pressed in case needs to quit
    [keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
    if keyIsDown
        trialData.validTrial = false;
        if keyCode(KbName('escape'))
            trialData.abortNow   = true;
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
        break;
    end

    %%% stim ON
    drawFixation(expInfo, expInfo.fixationInfo);
    if fullSeq(locNb)>0
        Screen('FillRect', expInfo.curWindow, black,CenterRectOnPoint(rectStim,xcoord(fullSeq(locNb)),ycoord));
    end
    if ismember(locNb,timeDots)
        yDot = (maxYdot-minYdot)*rand(1)+minYdot;
        Screen('FillOval', expInfo.curWindow, dimColour,CenterRectOnPoint(dotSize,xcoord(fullSeq(locNb)),yDot));
    end
    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    if locNb == 1
        stimStartTime = t;
    end
    
    %%% stim OFF
    %Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    drawFixation(expInfo, expInfo.fixationInfo);
    t = Screen('Flip', expInfo.curWindow, t + framesOn * ifi - ifi/2 );
        
    if checkTiming
        if t-prevStim > cycleDuration + ifi/2 || t-prevStim < cycleDuration - ifi/2
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

% Find the key values (not the same in PC and MAC) for the response loop
for keyVal=0:3
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end

if trialData.validTrial
    % response screen
    Screen('DrawText', expInfo.curWindow, 'Number of dots?', 0, expInfo.center(2), [0 0 0]);
    Screen('DrawText', expInfo.curWindow, ['(0-3)'], 0, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
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

