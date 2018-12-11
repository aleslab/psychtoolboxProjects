function [trialData] = trial_adjustDistance(expInfo, conditionInfo)
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
trialData.xMotion = conditionInfo.xMotion;

% % location should be a little bit random!
% % keep the stim between 4.8 and 6.2 eccentricity
% startLoc = rand(1);

locStim = ([conditionInfo.xloc conditionInfo(1).xloc+conditionInfo.xMotion]);
for loc=1:2
    xcoord(loc) = expInfo.center(1) + (locStim(loc) * expInfo.ppd);
end
ycoord = expInfo.center(2) - (conditionInfo.yloc * expInfo.ppd); 

adStimx(1) = expInfo.center(1) + conditionInfo.xlocT * expInfo.ppd;
adStimx(2) = adStimx(1);

% start trial
cycle = 0;interval=0;pressSpace=1;escape=1;

while pressSpace && escape == 1
    cycle = cycle+1;
    [keyIsDown, secs, keyCode]=KbCheck;
    if keyIsDown
        if keyCode(KbName('space'))
            pressSpace = 0;
        elseif keyCode(KbName('escape'))
            trialData.abortNow   = true;
            trialData.validTrial = false;
            trialData.response = 99;
            escape=0;
        elseif  keyCode(KbName('uparrow'))
            interval = interval + 0.05;
             if interval > 2
                interval = 2; Beeper;
             end
             adStimx(2) = adStimx(1) + interval*expInfo.ppd;
        elseif  keyCode(KbName('downarrow'))
            interval = interval - 0.05;
            if interval < 0
                interval =0; Beeper;
            end
            adStimx(2) = adStimx(1) + interval*expInfo.ppd;
        end
    end
    FlushEvents('keyDown');

    
    %%% stim ON
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,xcoord(mod(cycle,2)+1),ycoord));
    Screen('FillRect', expInfo.curWindow, stimCol,CenterRectOnPoint(rectStim,adStimx(mod(cycle,2)+1),ycoord));

    prevStim = t;
    t = Screen('Flip', expInfo.curWindow, t + framesOff * ifi - ifi/2);
    if cycle == 1
        trialData.stimStartTime = t;
    end
    
    %%% stim OFF
    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd);
    drawFixation(expInfo, expInfo.fixationInfo);
    t = Screen('Flip', expInfo.curWindow, t + framesOn * ifi - ifi/2 );
    
    if checkTiming
        if t-prevStim > cycleDuration + ifi/2 || t-prevStim < cycleDuration - ifi/2
            trialData.validTrial = false;
            break;
        end
    end
    
end

trialData.response = interval;
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;

trialData.trialDurationTotal = trialData.trialEndTime - trialData.trialStartTime ;
FlushEvents('keyDown');

end

