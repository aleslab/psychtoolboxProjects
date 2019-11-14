function [trialData] = trial_MAEv3(expInfo, conditionInfo)

trialData.validTrial = true;
trialData.abortNow   = false;
trialData.response = 'none';
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

%%% timing test:
nbTestCycles = conditionInfo.testDuration / (1/conditionInfo.testFreq);
trialData.nbTestCycles = nbTestCycles;

%%%%%%%%%%%%%%%%%
%%%% Gratings
texsize = conditionInfo.stimSize*expInfo.ppd; % Size of the grating image.
cyclespersecond = conditionInfo.tempFq; % temporal frequency (related to velocity)

% spatial freq of the 2 gratings
f1 = conditionInfo.f1/expInfo.ppd; % cycle/deg
f2 = conditionInfo.f2/expInfo.ppd; % cycle/deg

% direction of the 2 gratings
if strcmp(conditionInfo.direction,'right')
    angle1 = 180;
    angle2 = 0;
else % the overlapping stim in the test is the same in the left and the no-adaptation 
    % (see a few lines below how to construct grating3)
    angle1 = 0;
    angle2 = 180;
end
trialData.dir1 = angle1;
trialData.dir2 = angle2;

% Calculate parameters of the grating:
fr1=f1*2*pi;
fr2=f2*2*pi;

% Create gratings:
% the 2 gratings are created with the same sin 0 such that it gives a more
% 'edgy' stimulus (which is more natural and that the brain likes)
x = meshgrid(-texsize:texsize, -texsize:texsize);
grating1 = gray + inc*sin(fr1*x);
grating2 = gray + inc*sin(fr2*x);
if strcmp(conditionInfo.direction,'right')
    % overlapping test stim is mirrored
    grating3 = gray + (inc*sin(fr2*x) - inc*sin(fr1*x))/2;
else
    grating3 = gray + (inc*sin(fr1*x) - inc*sin(fr2*x))/2;
end

% add alpha column
grating1 = repmat(grating1,[1,1,3]);
grating1(:,:,4) = ones(size(grating1,1));
grating2 = repmat(grating2,[1,1,3]);
grating2(:,:,4) = ones(size(grating2,1))*.5;

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
gratingAdapt1 = Screen('MakeTexture', expInfo.curWindow, grating1 , [], [], [], [], glsl);
gratingAdapt2 = Screen('MakeTexture', expInfo.curWindow, grating2 , [], [], [], [], glsl);
twoGratings = Screen('MakeTexture', expInfo.curWindow, grating3 , [], [], [], [], glsl);

%%% shift
switch conditionInfo.f1
    case 0.125
        counterphaseF1 = 4;
    case 0.25
        counterphaseF1 = 2;
    case 0.5
        counterphaseF1 = 1;
    case 1
        counterphaseF1 = 0.5;
    case 2
        counterphaseF1 = 0.25;
end
switch conditionInfo.f2
    case 0.125
        counterphaseF1 = 4;
    case 0.25
        counterphaseF2 = 2;
    case 0.5
        counterphaseF2 = 1;
    case 1
        counterphaseF2 = 0.5;
    case 2
        counterphaseF2 = 0.25;
end

phaseDiv = 180/conditionInfo.phase;
if conditionInfo.phase == 180
    testShiftF1 = counterphaseF1 / phaseDiv * expInfo.ppd;
    testShiftF2 = counterphaseF2 / phaseDiv * expInfo.ppd;
elseif conditionInfo.phase == 0
    yoffset = conditionInfo.yoffset * expInfo.ppd;
else
    yoffset = counterphaseF1 / phaseDiv * expInfo.ppd;
end

% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize texsize*2/3];

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
shiftperframe1 = cyclespersecond * p1 * waitduration;
shiftperframe2 = cyclespersecond * p2 * waitduration;

% parameters for test
cycleDuration = 1/conditionInfo.testFreq;
framesPerCycle = 1/conditionInfo.testFreq * round(expInfo.monRefresh);
framesPerHalfCycle = framesPerCycle/2;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
if expInfo.useBitsSharp
    trialData.trigger = conditionInfo.trigger;
    ptbCorgiSendTrigger(expInfo,'conditionnumber',true,conditionInfo.trigger);
end
    
if expInfo.useBitsSharp
    f1Trigger = expInfo.triggerInfo.ssvepTagF1;
    checkTime = 1;
    ptbCorgiSendTrigger(expInfo,'starttrial',true);
else
    f1Trigger = 1;
    checkTime = 0;
end

drawFixation(expInfo, expInfo.fixationInfo);
vbl = Screen('Flip', expInfo.curWindow);
trialData.trialStartTime = vbl;

vblAdaptTime = vbl + conditionInfo.adaptDuration;
trialData.adaptTime = vblAdaptTime;

% yEcc = 300;
% i=0;
% yoffset1 = mod(i*shiftperframe1,p1);
% yoffset2 = mod(i*shiftperframe2,p2);
% Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc),angle1, [], [], [], [], [], [0,yoffset1, 0, 0]);
% Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc),angle2, [], [], [], [], [], [0, yoffset2, 0, 0]);
% Screen('DrawTexture', expInfo.curWindow, twoGratings, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)+yEcc),[], [], [], [], [], [], [0, 0, 0, 0]);
% Screen('Flip', expInfo.curWindow);
% i=i+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADAPTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0; % incremental shift of the gratings 
if strcmp(conditionInfo.direction,'none')
    %%%%%%%%%%%%%%%%% No adaptation
    while (vbl < vblAdaptTime) && ~trialData.abortNow 
        i=i+1;
        Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)), angle1);
        if conditionInfo.overlap
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)), angle2);
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * expInfo.ifi);
    end
else
    %%%%%%%%%%%%%%%%%
    %%% Adaptation loop: Run for 10 s or keypress.
    while (vbl < vblAdaptTime) && ~trialData.abortNow 
        
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
        Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
        if conditionInfo.overlap
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)), angle2, [], [], [], [], [], [0, yoffset2, 0, 0]);
        end
        drawFixation(expInfo, expInfo.fixationInfo);
        % Flip 'waitframes' monitor refresh intervals after last redraw.
        vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * expInfo.ifi);

    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test presented right after the end of adaptation = no stimulus onset that
% would create an ERP so that we can record SSVEP earlier 

cycle = 0;
response=zeros(1,nbTestCycles);
while cycle<nbTestCycles && trialData.validTrial 
    % check key press for half cycle 
    [keyDown, secs, keyCode] = KbCheck(expInfo.deviceIndex);
    if keyDown
        if keyCode(KbName('LeftArrow'))
            response(cycle+1) = 1;
        elseif keyCode(KbName('RightArrow'))
            response(cycle+1) = 2;
        elseif keyCode(KbName('DownArrow'))
            response(cycle+1) = 3;
        elseif keyCode(KbName('ESCAPE'))    
            trialData.abortNow   = true;
            trialData.response = 'abort';
        end
    else
        response(cycle+1) = 0;
    end
        
    % first stim
    if conditionInfo.overlap
        if conditionInfo.phase == 180
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle1, [], [], [], [], [], [0, 0, 0, 0]);
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle2, [], [], [], [], [], [0, 0, 0, 0]);
        else
            Screen('DrawTexture', expInfo.curWindow, twoGratings, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),[], [], [], [], [], [], [0, 0, 0, 0]);
        end
    else
       Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle1, [], [], [], [], [], [0, 0, 0, 0]);       
    end
    drawFixation(expInfo, expInfo.fixationInfo);
    ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
    vbl1 = vbl;
    if cycle == 0
        trialData.trialTestTime = vbl;
    elseif checkTime
        if vbl1 - vbl2 > cycleDuration/2 + expInfo.ifi/2 || vbl1 - vbl2 < cycleDuration/2 - expInfo.ifi/2
            trialData.validTrial = false;
        end
    end

    % second stim
    if conditionInfo.overlap
        if conditionInfo.phase == 180
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle1, [], [], [], [], [], [0, testShiftF1, 0, 0]);
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle2, [], [], [], [], [], [0, testShiftF2, 0, 0]);
        else
            Screen('DrawTexture', expInfo.curWindow, twoGratings, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),[], [], [], [], [], [], [0, yoffset, 0, 0]);
        end
    else
         if conditionInfo.phase == 180
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle1, [], [], [], [], [], [0, testShiftF1, 0, 0]);       
         else
            Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)),angle1, [], [], [], [], [], [0, yoffset, 0, 0]);       
         end
    end
    drawFixation(expInfo, expInfo.fixationInfo);
    ptbCorgiSendTrigger(expInfo,'clear',0);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
    vbl2 = vbl;
    if checkTime
        if vbl2 - vbl1 > cycleDuration/2 + expInfo.ifi/2 || vbl2 - vbl1 < cycleDuration/2 - expInfo.ifi/2
            trialData.validTrial = false;
        end
    end
    
    % increment cycle
    cycle = cycle+1;
end

drawFixation(expInfo, expInfo.fixationInfo);
if expInfo.useBitsSharp
    if trialData.validTrial
        ptbCorgiSendTrigger(expInfo,'raw',0,f1Trigger);
    else
        ptbCorgiSendTrigger(expInfo,'raw',1,abortExpTrigger); % abort trial
    end
end
trialData.trialEndTime = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * expInfo.ifi);
if trialData.validTrial
    trialData.testDuration = trialData.trialEndTime - trialData.trialTestTime;
    trialData.trialDuration = trialData.trialEndTime - trialData.trialStartTime;
end

trialData.allResp = response;

% while KbEventAvail(expInfo.deviceIndex)
%     [trialData.evt] = KbEventGet(expInfo.deviceIndex);
% end 
% KbQueueRelease(expInfo.deviceIndex);
% KbEventFlush(expInfo.deviceIndex);

%%%% close all the textures
Screen('Close', [gratingAdapt1, gratingAdapt2, twoGratings]);

ptbCorgiSendTrigger(expInfo,'clear',0);
drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);


if expInfo.useBitsSharp
    ptbCorgiSendTrigger(expInfo,'endtrial',true);
end
    
end


