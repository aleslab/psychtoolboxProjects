function [trialData] = trial_DCrating_addition(expInfo, conditionInfo)
% if the escape key is pressed then the experiment is aborted
% press space to pause the experiment

stimStartTime = 0;


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



%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); % - above
xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd); % + right
eccMotion = xcoord + (conditionInfo.xMotion * expInfo.ppd);
% loc1 = conditionInfo.loc1 * expInfo.ppd;
% loc2 = conditionInfo.loc2 * expInfo.ppd;



%%% stimulus
if conditionInfo.stim == 2
    stimCol = 0.47; % 0.55 = 10% contrast, 0.47 = 6% (47 is towards black)
else
    stimCol = BlackIndex(expInfo.curWindow);
end

texRect = conditionInfo.texRect*expInfo.ppd;
baseImg = double(rand(50,50)>.5) * 0.5+.25;
baseTex = Screen('MakeTexture',expInfo.curWindow,baseImg);
img2 = baseImg;
imgMov = baseImg;
% img2(2:23,11:14) = img2(2:23,11:14) *-1+1;
% img2(2:23,11:14) = img2(2:23,11:14) *-0.5+.25;
img2(5:46,24:27  ) = (baseImg(5:46,24:27) -.25) * 2;
img2Tex = Screen('MakeTexture',expInfo.curWindow,img2);
imgMov(5:46,29:32) = (baseImg(5:46,29:32 ) -.25) * 2;
imgMovTex = Screen('MakeTexture',expInfo.curWindow,imgMov);

% xPos=[];yPos=[];
% for bx=0:0.5:conditionInfo(1).sizeBack(1)
%     for by=0:0.5:conditionInfo(1).sizeBack(2)
% %         tmp = rand(1)/4;
% %         xPos = [xPos tmp + bx  tmp + bx + lineSize];
% %         yPos = [yPos tmp + by tmp + by + lineSize];
%         xPos = [xPos bx bx + conditionInfo(1).lineSize];
%         yPos = [yPos by by + conditionInfo(1).lineSize];
%     end
% end
% xPos = xPos*expInfo.ppd  - (conditionInfo(1).sizeBack(1)/2 * expInfo.ppd) - conditionInfo(1).lineSize/2*expInfo.ppd;
% yPos = yPos*expInfo.ppd - (conditionInfo(1).sizeBack(2)/2 * expInfo.ppd ) - conditionInfo(1).lineSize/2*expInfo.ppd;
%
%
% topStim = [0-conditionInfo(1).lineSize/2 0-conditionInfo(1).lineSize/2 conditionInfo(1).size_S(1)+conditionInfo(1).lineSize/2 conditionInfo(1).size_S(2)+conditionInfo(1).lineSize/2]*expInfo.ppd;
% xPos_S=[];yPos_S=[];
% for bx=0.5:0.5:conditionInfo(1).size_S(1)
%     for by=0:0.5:conditionInfo(1).size_S(2)-0.5
% %         tmp = rand(1)/4;
% %         xPos_S = [xPos_S  tmp + bx   tmp + bx - lineSize];
% %         yPos_S = [yPos_S tmp + by  tmp + by + lineSize];
%         xPos_S = [xPos_S  bx   bx - conditionInfo(1).lineSize];
%         yPos_S = [yPos_S by  by + conditionInfo(1).lineSize];
%     end
% end
% xPos_S = xPos_S*expInfo.ppd  - (conditionInfo(1).size_S(1)/2 * expInfo.ppd) - conditionInfo(1).lineSize/2*expInfo.ppd;
% yPos_S = yPos_S*expInfo.ppd - (conditionInfo(1).size_S(2)/2 * expInfo.ppd ) + conditionInfo(1).lineSize/2*expInfo.ppd;


% start trial
for cycleNb = 1 : nbTotalCycles
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
    if conditionInfo.motion == 1 && mod(cycleNb,2)==0 % in motion
        x_coord = eccMotion; imgTex = imgMovTex;
    else
        x_coord = xcoord;imgTex = img2Tex;
    end
    if conditionInfo.stim < 3
        Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,x_coord,ycoord));
    elseif conditionInfo.stim == 3
        %         Screen('DrawTexture', expInfo.curWindow, baseText, [],CenterRectOnPoint(rectStim,x_coord,ycoord));
        Screen('DrawTexture', expInfo.curWindow, imgTex, [],CenterRectOnPoint(texRect,xcoord,ycoord),[],0);
        %         Screen('DrawLines', expInfo.curWindow, [xPos; yPos], [], stimCol, [xcoord ycoord],1); % not moving so always use xcoord
        %         Screen('FillRect', expInfo.curWindow, expInfo.bckgnd,CenterRectOnPoint(topStim,x_coord,ycoord));
        %         Screen('DrawLines', expInfo.curWindow, [xPos_S; yPos_S], [], stimCol, [x_coord ycoord],1);
    end
%     Screen('FrameRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,x_coord,ycoord));
    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    if cycleNb == 1
        stimStartTime = t;
    end
    
    %%% stim OFF
    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    if conditionInfo.stim == 3
        Screen('DrawTexture', expInfo.curWindow, baseTex, [],CenterRectOnPoint(texRect,xcoord,ycoord),[],0);
        %         Screen('DrawLines', expInfo.curWindow, [xPos; yPos], [], stimCol, [xcoord ycoord],1); % not moving so always use xcoord
    end
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
    Screen('DrawText', expInfo.curWindow, 'Did the stimulus move back and forth horizontally?', 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
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

