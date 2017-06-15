function [trialData] = trial_longRange(expInfo, conditionInfo)
% give feedback for correct/incorrect answer?
% what would be best for VEP, white or black flashes??

% if a key is pressed during a trial, it stops the trial and becomes
% invalid
% if the escape key is pressed then the experiment is aborted

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;

black = BlackIndex(expInfo.curWindow);
dimColour = 0.3;

% parameters for the task
trialData.dims = randi((conditionInfo.maxDim+1),1)-1; % number of dims for this trial
trialData.flipDim = [11 12 13];
% determine which flip with dim, 2 dims should not follow each other on the
% same stimulus
if conditionInfo.motion 
    trialData.flipDim = randsample(1:3:(conditionInfo.totFlip),trialData.dims)-1; % Attention 1st flip = 0
    % was first planning to only avoid dim+3 but seems complicated, here it
    % only allows a dim every 3 frames
%     while ismember(1,diff(trialData.flipDim)==1) % do it again until there is no 2 successive flips
%         trialData.flipDim = sort(randperm(conditionInfo.totFlip+1,trialData.dims)-1); % if motion then any flip BUT avoid 2 successive flips + Attention 1st flip = 0
%     end
else % if no motion then it has to be when the stim is on (only odd numbers) + avoid successive dims
    trialData.flipDim = randsample(1:4:(conditionInfo.totFlip),trialData.dims)-1; % Attention 1st flip = 0
end

% stim presentation parameters
rectCircle = conditionInfo.stimSize*expInfo.ppd;
nbFrames = conditionInfo.nFramesPerStim;
ifi = expInfo.ifi;
ycoord = expInfo.center(2)/2;
xcoord = conditionInfo.xloc(1)*expInfo.ppd; % to be substracted or added 
movingStep = conditionInfo.movingStep;
if strcmp(conditionInfo.sideStim,'left')
    xcoordSingle = expInfo.center(1)-xcoord;
elseif strcmp(conditionInfo.sideStim,'right')
    xcoordSingle = expInfo.center(1)+xcoord;
end
% % only required if the trial ends depending on the position of the stimulus
% % (mainly for the sweep condition)
% if strcmp(conditionInfo.label,'sweep')
%     xcoordEnd = expInfo.center(1)/conditionInfo.xloc(2);
% else
%     xcoordEnd = expInfo.center(1)/conditionInfo.xloc(1);
% end

% check the nb of flip
flipNb = 0;

stimStartTime = trialData.trialStartTime; % this is wrong but need a starting value for the while loop

% presentation stimulus
while ~KbCheck && t<conditionInfo.stimDuration+stimStartTime - ifi/2 % && xcoord<xcoordEnd+1
    if strcmp(conditionInfo.sideStim,'both') % 2 stim presented
        if conditionInfo.motion == 1 % in motion
            % check if the flip is dim
            if ismember(flipNb,trialData.flipDim)
                colStim = dimColour;
            else
                colStim = black;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
            % t- trialData.trialStartTime
            flipNb = flipNb+ 1;
            if flipNb == 1
                stimStartTime = t;
            end
            % check if the flip is dim
            if ismember(flipNb,trialData.flipDim)
                colStim = dimColour;
            else
                colStim = black;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
            % t- trialData.trialStartTime
            if strcmp(conditionInfo.label,'sweep')
                xcoord = xcoord + movingStep;
            end
            flipNb = flipNb+ 1;
        else % simultaneous condition
            % check if the flip is dim
            if ismember(flipNb,trialData.flipDim)
                colStim = Shuffle([dimColour,black]);
            else
                colStim = [black black];
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            Screen('FillRect', expInfo.curWindow, colStim(1),CenterRectOnPoint(rectCircle,expInfo.center(1)-xcoord,ycoord));
            Screen('FillRect', expInfo.curWindow, colStim(2),CenterRectOnPoint(rectCircle,expInfo.center(1)+xcoord,ycoord));
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
            flipNb = flipNb+ 1;
            if flipNb == 1
                stimStartTime = t;
            end
            drawFixation(expInfo, expInfo.fixationInfo);
            t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
            flipNb = flipNb+ 1;
        end
    else  % only one stim (left or right)
        % check if the flip is dim
        if ismember(flipNb,trialData.flipDim)
            colStim = dimColour;
        else
            colStim = black;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('FillRect', expInfo.curWindow, colStim,CenterRectOnPoint(rectCircle,xcoordSingle,ycoord));
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
        flipNb = flipNb+ 1;
        if flipNb == 1
            stimStartTime = t;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        t = Screen('Flip', expInfo.curWindow, t + nbFrames * ifi - ifi/2);
        flipNb = flipNb+ 1;
    end
end

trialData.stimEndTime = t;
trialData.stimStartTime = stimStartTime;

% abort
[keyIsDown, secs, keyCode]=KbCheck(expInfo.deviceIndex);
if keyIsDown
    trialData.validTrial = false;
    if keyCode(KbName('escape'))
        trialData.abortNow   = true;
    end
end



% Find the key values (not the same in PC and MAC) for the loop in the response
for keyVal=0:conditionInfo.maxDim
    vectKeyVal(keyVal+1) = KbName(num2str(keyVal));
end


trialData.totFlip = flipNb;
if flipNb ~= conditionInfo.totFlip
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

if trialData.response==999 % no response
    trialData.validTrial = false;
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.stimDurationReal = trialData.stimEndTime - trialData.stimStartTime ; 
trialData.trialDurationReal = trialData.trialEndTime - trialData.trialStartTime ; 

% trialData

end

