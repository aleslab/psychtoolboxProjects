function [trialData] = trial_diffSpacing(expInfo, conditionInfo)
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

% nbTotalCycles = ceil(conditionInfo.trialDuration * conditionInfo.stimTagFreq);
% trialDuration = nbTotalCycles * cycleDuration; % =11.67060200

% save it in the data output structure
% trialData.framesPerCycle = framesPerCycle;
trialData.framesOn = framesOn;
trialData.framesOff = framesOff;
trialData.timeStimOn = timeStimOn;
trialData.timeStimOff = timeStimOff;
% trialData.nbTotalCycles = nbTotalCycles;
% trialData.trialDuration = trialDuration;
trialData.cycleDuration = cycleDuration;

% presentLeftHF = 0; % randi([0 1]);
% trialData.presentLeftHF = presentLeftHF;


% if presentLeftHF
%     xcoord = expInfo.center(1) - (conditionInfo.xloc * expInfo.ppd); % + right
% else
%     xcoord = expInfo.center(1) + (conditionInfo.xloc * expInfo.ppd); % + right
% end
% loc1 = conditionInfo.loc1 * expInfo.ppd;
% loc2 = conditionInfo.loc2 * expInfo.ppd;



%%% stimulus
stimCol = BlackIndex(expInfo.curWindow);
% stimCol = 0.47;
% if conditionInfo.stim == 1
%     stimCol = 0.47; % 0.55 = 10% contrast, 0.47 = 6% (47 is towards black)
% else
%     stimCol = BlackIndex(expInfo.curWindow);
% end

% texRect = conditionInfo.texRect*expInfo.ppd;
% baseImg = double(rand(100,100)>.5) * 0.5+.25;
% baseTex = Screen('MakeTexture',expInfo.curWindow,baseImg);
% img2 = baseImg;
% imgMov = baseImg;
% img2(2:23,11:14) = img2(2:23,11:14) *-1+1;
% img2(2:23,11:14) = img2(2:23,11:14) *-0.5+.25;
% img2(5:46,24:27) = (baseImg(5:46,24:27) -.25) * 2;
% img2Tex = Screen('MakeTexture',expInfo.curWindow,img2);
% imgMov(5:46,29:32) = (baseImg(5:46,29:32 ) -.25) * 2;
% imgMovRight = Screen('MakeTexture',expInfo.curWindow,imgMov);

% img2(40:60,44:45) = (baseImg(40:60,44:45) -.25) * 2;
% img2Tex = Screen('MakeTexture',expInfo.curWindow,img2);
% if conditionInfo.xMotion == 0.1
%     imgMov(40:60,46:47) = (baseImg(40:60,46:47 ) -.25) * 2;
%     imgMovTex = Screen('MakeTexture',expInfo.curWindow,imgMov);
% elseif conditionInfo.xMotion == 0.6
%     imgMov(40:60,52:53) = (baseImg(40:60,52:53 ) -.25) * 2;
%     imgMovTex = Screen('MakeTexture',expInfo.curWindow,imgMov);
% end



%%% stim presentation
rectStim = conditionInfo.stimSize*expInfo.ppd;
trialData.spacing = conditionInfo.spacing;

% location should be a little bit random!
% keep the stim between 4.9 and 6.1 eccentricity
startLoc = rand(1);
if startLoc > 0.5
    trialData.direction = 1;
else
    trialData.direction = 2;
end

xcoord = expInfo.center(1) + ((conditionInfo.xloc + startLoc) * expInfo.ppd);
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); % - above
m_coord = xcoord;

% start trial
for ss=1:2

    if ss==2
        if trialData.direction == 1  
            m_coord = xcoord - (conditionInfo.spacing * expInfo.ppd); 
        elseif trialData.direction == 2 
            m_coord = xcoord + (conditionInfo.spacing * expInfo.ppd); 
        end
    end
    
    %     if conditionInfo.xMotion > 0
%         if trialData.direction == 1 && ss == 1 || trialData.direction == 2 && ss == 2 % present the stim on the right
%             m_coord = mcoord + (conditionInfo.xMotion * expInfo.ppd); 
%         elseif trialData.direction == 1 && ss == 2 || trialData.direction == 2 && ss == 1
%             m_coord = mcoord; 
%         end
%     else
%         m_coord = mcoord; 
%     end
    
%     if conditionInfo.xMotion > 0
%         if trialData.direction == 1 && ss == 1 || trialData.direction == 2 && ss == 2 % present the stim on the right
%             x_coord = xcoord + (conditionInfo.xMotion * expInfo.ppd); imgTex = imgMovTex;
%         elseif trialData.direction == 1 && ss == 2 || trialData.direction == 2 && ss == 1
%             x_coord = xcoord; imgTex = img2Tex;
%         end
%     else
%         x_coord = xcoord; imgTex = img2Tex;
%     end


    %%% stim ONstimSize = [0 0 0.1 2]
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,m_coord,ycoord));
     
    
    %     if conditionInfo.stim == 1
%         Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,x_coord,ycoord));
%     elseif conditionInfo.stim == 2
%         Screen('DrawTexture', expInfo.curWindow, imgTex, [],CenterRectOnPoint(texRect,xcoord,ycoord),[],0);
%     end
    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    if ss == 1
        stimStartTime = t;
    end
    
    %%% stim OFF
    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
%     if conditionInfo.stim == 2
%         Screen('DrawTexture', expInfo.curWindow, baseTex, [],CenterRectOnPoint(texRect,xcoord,ycoord),[],0);
%     end
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



if trialData.validTrial
    % response screen
    Screen('DrawText', expInfo.curWindow, 'Direction of the stimulus?', 0, expInfo.center(2)-expInfo.center(2)/2, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'left arrow', 0, expInfo.center(2)+expInfo.center(2)/8, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'right arrow', 0, expInfo.center(2)+expInfo.center(2)*2/8, [0 0 0]);
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

