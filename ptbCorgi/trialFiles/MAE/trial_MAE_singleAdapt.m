function [trialData] = trial_MAE_singleAdapt(expInfo, conditionInfo)
% 10 s adaptation followed by 5 s test
% if 1st trial then longer adaptation
% trial not stopped if a random key is pressed 
% Problem: if invalid trial then it is put at the end of the experiment,
% not at the end of the block!

trialData.validTrial = true;
trialData.abortNow   = false;
trialData.response = 999;
abortExpTrigger = 99;

% Find the color values which correspond to white and black.
white=WhiteIndex(expInfo.curWindow);
black=BlackIndex(expInfo.curWindow);
gray=(white+black)/2;
inc=white-gray;

% Enable alpha blending
Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(expInfo.curWindow, 'SeparateAlphaChannel');


%%%%%%%%%%%%%%%%%
%%%% Gratings
texsize = conditionInfo.stimSize*expInfo.ppd; % Size of the grating image.
cyclespersecond1 = conditionInfo.tempFq; % temporal frequency (related to velocity)
cyclespersecond2 = cyclespersecond1; % same for both gratings

% spatial freq of the 2 gratings
f1 = conditionInfo.f1/expInfo.ppd; % cycle/deg
f2 = conditionInfo.f2/expInfo.ppd;
% direction of the 2 gratings
if conditionInfo.direction == 99 % present only one grating
    angle1 = 0;
    if conditionInfo.f2 == 2
        angle2 = 0;
    elseif conditionInfo.f2 == 0.125
        angle2 = 180;
    end
elseif conditionInfo.direction == 180
    angle1 = 180;
    angle2 = 0;
elseif conditionInfo.direction == 0
    angle1 = 0;
    angle2 = 180;
end
trialData.angle1 = angle1;
trialData.angle2 = angle2;

% Calculate parameters of the grating:
fr1=f1*2*pi;
fr2=f2*2*pi;

% Create gratings:
x = meshgrid(-texsize:texsize, -texsize:texsize);
grating1 = gray + inc*sin(fr1*x);
x2 = meshgrid(-texsize:texsize, -texsize:texsize);
grating2 = gray + inc*sin(fr2*x2);
% add alpha column
grating1 = repmat(grating1,[1,1,3]);
grating2 = repmat(grating2,[1,1,3]);
grating1(:,:,4) = ones(size(grating1,1));
grating2(:,:,4) = ones(size(grating2,1))*.5;

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
gratingAdapt1 = Screen('MakeTexture', expInfo.curWindow, grating1 , [], [], [], [], glsl);
gratingAdapt2 = Screen('MakeTexture', expInfo.curWindow, grating2 , [], [], [], [], glsl);


% create gratings for the test
% the 2 gratings are created with the same sin 0 such that it gives a more
% 'edgy' stimulus (which is more natural and that the brain likes)
phase = conditionInfo.testPhase * pi/180; 
gratingT1 = gray + inc*sin(fr1*x + phase);
gratingT2 = gray + inc*sin(fr2*x2 + phase);
% add alpha column
gratingT1 = repmat(gratingT1,[1,1,3]);
gratingT2 = repmat(gratingT2,[1,1,3]);
gratingT1(:,:,4) = ones(size(gratingT1,1));
gratingT2(:,:,4) = ones(size(gratingT2,1))*.5;
% make texture
gratingPhaseShift1 = Screen('MakeTexture', expInfo.curWindow, gratingT1);
gratingPhaseShift2 = Screen('MakeTexture', expInfo.curWindow, gratingT2);
gratingtest1 = Screen('MakeTexture', expInfo.curWindow, grating1);
gratingtest2 = Screen('MakeTexture', expInfo.curWindow, grating2);

% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize texsize/2];
yEcc = conditionInfo.yEccentricity * expInfo.ppd;

%%%%%%%%%%%%%%%%%
%%% timing for presentation
waitframes = 1;
waitduration = waitframes * expInfo.ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding!
p1 = 1/f1; % pixels/cycle
p2 = 1/f2; % pixels/cycle

% Translate requested speed of the gratings (in cycles per second) into
% a shift value in "pixels per frame", assuming given waitduration:
shiftperframe1 = cyclespersecond1 * p1 * waitduration;
shiftperframe2 = cyclespersecond2 * p2 * waitduration;

% parameters for test
cycleDuration = 1/conditionInfo.testFreq;
framesPerCycle = 1/conditionInfo.testFreq * round(expInfo.monRefresh);
framesPerHalfCycle = framesPerCycle/2;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
if expInfo.useBitsSharp
    f1Trigger = expInfo.triggerInfo.ssvepTagF1;
    checkTime = 1;
else
    f1Trigger = 1;
    checkTime = 0;
end
if expInfo.useBitsSharp 
    ptbCorgiSendTrigger(expInfo,'starttrial',true);
end
drawFixation(expInfo, expInfo.fixationInfo);
vbl = Screen('Flip', expInfo.curWindow);
trialData.trialStartTime = vbl;

if expInfo.currentTrial.number == 1
    trialAdaptDuration = conditionInfo.adaptDuration + conditionInfo.longAdapt;
else
    trialAdaptDuration = conditionInfo.adaptDuration;
end
vblAdaptTime = vbl + trialAdaptDuration;
trialData.adaptTime = vblAdaptTime;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADAPTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0; % incremental shift of the gratings 
%%%%%%%%%%%%%%%%%
%%% Adaptation loop: Run for 10 s or keypress.
while (vbl < vblAdaptTime) && ~trialData.abortNow % && ~KbCheck(expInfo.deviceIndex)
    drawFixation(expInfo, expInfo.fixationInfo);
    
    % Shift the grating by "shiftp2perframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    yoffset1 = mod(i*shiftperframe1,p1);
    yoffset2 = mod(i*shiftperframe2,p2);
    i=i+1;
    
    % Draw gratings texture, rotated by "angle":
    Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc), angle2, [], [], [], [], [], [0, yoffset2, 0, 0]);
    if conditionInfo.direction ~= 99
        Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
    end
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * expInfo.ifi);
    
    [keyDown, secs, keyCode] = KbCheck(expInfo.deviceIndex);
    if keyDown
        if keyCode(KbName('ESCAPE'))
            trialData.abortNow   = true;
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        Screen('DrawText', expInfo.curWindow, 'please do not press a key', 150, expInfo.center(2)-expInfo.center(2)/4, [0 0 0]);
        vbl = Screen('Flip',expInfo.curWindow);
        vblAdaptTime = vbl + trialAdaptDuration;
        trialData.adaptTime = vblAdaptTime;
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test presented right after the end of adaptation = no stimulus onset that
% would create an ERP so that we can record SSVEP earlier 

cycle = 0;
while cycle<conditionInfo.testDuration && trialData.validTrial % ~KbCheck(expInfo.deviceIndex)
    % first stim
    drawFixation(expInfo, expInfo.fixationInfo);
    if conditionInfo.direction ~= 99
        Screen('DrawTexture', expInfo.curWindow, gratingtest1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc));
    end
    Screen('DrawTexture', expInfo.curWindow, gratingtest2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc));
    ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
    vbl1 = vbl;
    if cycle == 0
        trialData.trialTestTime = vbl;
    elseif checkTime
%         vbl1 - vbl2
        if vbl1 - vbl2 > cycleDuration/2 + expInfo.ifi/2 || vbl1 - vbl2 < cycleDuration/2 - expInfo.ifi/2
            trialData.validTrial = false;
        end
    end
    
    % second stim
    drawFixation(expInfo, expInfo.fixationInfo);
    if conditionInfo.direction ~= 99
        Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc));
    end
    Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc));
    ptbCorgiSendTrigger(expInfo,'clear',0);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
    vbl2 = vbl;
    
    if checkTime
%         vbl2 - vbl1
        if vbl2 - vbl1 > cycleDuration/2 + expInfo.ifi/2 || vbl2 - vbl1 < cycleDuration/2 - expInfo.ifi/2
            trialData.validTrial = false;
        end
    end
    
    [keyDown, secs, keyCode] = KbCheck(expInfo.deviceIndex);
    if keyDown
        trialData.validTrial = false;
        if keyCode(KbName('ESCAPE'))
            trialData.abortNow   = true;
        end
    end
    
    % increment cycle
    cycle = cycle+1;
end

drawFixation(expInfo, expInfo.fixationInfo);
if expInfo.useBitsSharp
    if trialData.validTrial
        ptbCorgiSendTrigger(expInfo,'endtrial',true); % should be sent with the last flip
    else
        ptbCorgiSendTrigger(expInfo,'raw',1,abortExpTrigger); % abort trial
    end
end
trialData.trialEndTime = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
trialData.testDuration = trialData.trialEndTime - trialData.trialTestTime;
trialData.trialDuration = trialData.trialEndTime - trialData.trialStartTime;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESPONSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get response: direction of MAE
if trialData.validTrial
    % response screen
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('DrawText', expInfo.curWindow, 'direction of the after effect?', 150, expInfo.center(2)-expInfo.center(2)/4, [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'left arrow, right arrow', 150, expInfo.center(2), [0 0 0]);
    Screen('DrawText', expInfo.curWindow, 'down arrow for no effect', 150, expInfo.center(2)+expInfo.center(2)/4, [0 0 0]);
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 
        [keyDown, secs, keyCode] = KbCheck(expInfo.deviceIndex);
        if keyDown
            if keyCode(KbName('LeftArrow'))
                trialData.response = 'LeftArrow';
            elseif keyCode(KbName('RightArrow'))
                trialData.response = 'RightArrow';
            elseif keyCode(KbName('DownArrow'))
                trialData.response = 'DownArrow';
            elseif keyCode(KbName('ESCAPE'))
                trialData.abortNow   = true;
                trialData.response = 'Abort';
            else
                Screen('DrawText', expInfo.curWindow, 'not an existing response key', 150, expInfo.center(2)-expInfo.center(2)/4, [0 0 0]);
                Screen('DrawText', expInfo.curWindow, 'please choose left, right or down arrow', 50, expInfo.center(2), [0 0 0]);
                Screen('Flip',expInfo.curWindow);
            end
        end
    end
    FlushEvents('keyDown');    
end

    
end


