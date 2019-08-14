function [trialData] = trial_testMAE(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(0.1);
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;

%%%%%%%%%%%%%%%%%
%%% Screen 

% Find the color values which correspond to white and black.
white=WhiteIndex(expInfo.curWindow);
black=BlackIndex(expInfo.curWindow);
gray=(white+black)/2;
inc=white-gray;

% Enable alpha blending
Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(expInfo.curWindow, 'SeparateAlphaChannel');


%%%%%%%%%%%%%%%%%
%%%% Gratings
texsize = conditionInfo.stimSize*expInfo.ppd; % Half-Size of the grating image.
cyclespersecond1 = conditionInfo.tempFq; % temporal frequency (related to velocity) 
cyclespersecond2 = cyclespersecond1; % same for both gratings

% spatial freq of the 2 gratings
f1 = conditionInfo.f1/expInfo.ppd; % cycle/deg
f2 = conditionInfo.f2/expInfo.ppd;
% direction of the 2 gratings picked randomly
possibleAngles = Shuffle([0 180]); % 0=right, 180=left
angle1=possibleAngles(1);
angle2=possibleAngles(2);
trialData.angle1 = angle1;
trialData.angle2 = angle2;

% Calculate parameters of the grating:
p1=ceil(1/f1); % pixels/cycle, rounded up.
p2=ceil(1/f2);
fr1=f1*2*pi;
fr2=f2*2*pi;


% Create gratings:
x = meshgrid(-texsize:texsize + p1, -texsize:texsize);
grating1 = gray + inc*cos(fr1*x);
x2 = meshgrid(-texsize:texsize + p2, -texsize:texsize);
grating2 = gray + inc*cos(fr2*x2);

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
gratingAdapt1 = Screen('MakeTexture', expInfo.curWindow, grating1 , [], [], [], [], glsl);
gratingAdapt2 = Screen('MakeTexture', expInfo.curWindow, grating2 , [], [], [], [], glsl);

% create gratings for the test
phase = conditionInfo.testPhase * pi/180; % counterphase
gratingT1 = gray + inc*cos(fr1*x + phase);
gratingT2 = gray + inc*cos(fr2*x2 + phase);
gratingPhaseShift1 = Screen('MakeTexture', expInfo.curWindow, gratingT1);
gratingPhaseShift2 = Screen('MakeTexture', expInfo.curWindow, gratingT2);
gratingtest1 = Screen('MakeTexture', expInfo.curWindow, grating1);
gratingtest2 = Screen('MakeTexture', expInfo.curWindow, grating2);

% assignin('base','g',grating1)

% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize*2 texsize];
yEcc = conditionInfo.yEccentricity * expInfo.ppd;

%%%%%%%%%%%%%%%%%
adaptDuration=2; % Adaptation duration 30 s

%%% timing for presentation
% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', expInfo.curWindow);
waitframes = 1;
waitduration = waitframes * ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding!
p1 = 1/f1; % pixels/cycle
p2 = 1/f2; % pixels/cycle

% Translate requested speed of the gratings (in cycles per second) into
% a shift value in "pixels per frame", assuming given waitduration:
shiftperframe1 = cyclespersecond1 * p1 * waitduration;
shiftperframe2 = cyclespersecond2 * p2 * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
drawFixation(expInfo, expInfo.fixationInfo);
vbl = Screen('Flip', expInfo.curWindow);

vblAdaptTime = vbl + adaptDuration;
i=0;


%%%%%%%%%%%%%%%%%
%%% Adaptation loop: Run for 30 s or keypress.
while (vbl < vblAdaptTime) && ~KbCheck
    drawFixation(expInfo, expInfo.fixationInfo);
    
    % Shift the grating by "shiftperframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    yoffset1 = mod(i*shiftperframe1,p1);
    yoffset2 = mod(i*shiftperframe2,p2);
    i=i+1;
    
    % Draw first grating texture, rotated by "angle":
%     Screen('DrawTexture', w, gratingtex1, srcRect, [], angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
%     Screen('DrawTexture', w, gratingtex2, srcRect, [], angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);
    Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
    Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);
    
%     % just for fun to check
%     Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1)-200,expInfo.center(2)+yEcc), angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
%     Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1)+200,expInfo.center(2)+yEcc), angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);

        
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * ifi);
end

%%%%%%%%%%%%%%%%%
framesPerCycle = 1/conditionInfo.testFreq * round(expInfo.monRefresh);
framesPerHalfCycle = framesPerCycle/2;
testDuration = 10;
drawFixation(expInfo, expInfo.fixationInfo);
vbl = Screen('Flip', expInfo.curWindow);
vblTestTime = vbl + testDuration;

% %%% test stimulus (flicker)
% while (vbl < vblTestTime) && ~KbCheck
%     drawFixation(expInfo, expInfo.fixationInfo);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1, [], 0.5);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2, [], 0.5);
%     vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);
%     % move the entire stimulus (overlapping gratings)
%     drawFixation(expInfo, expInfo.fixationInfo);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest1, [], CenterRectOnPoint(srcRect,expInfo.center(1)+moveTest,expInfo.center(2)-yEcc), angle1, [], 0.5);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest2, [], CenterRectOnPoint(srcRect,expInfo.center(1)+moveTest,expInfo.center(2)-yEcc), angle2, [], 0.5);
%     vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);    
% end

%%% test stimulus (flicker)
while (vbl < vblTestTime) && ~KbCheck
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('DrawTexture', expInfo.curWindow, gratingtest1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1, [], 0.5);
    Screen('DrawTexture', expInfo.curWindow, gratingtest2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2, [], 0.5);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);
    % move the entire stimulus (overlapping gratings)
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1, [], 0.5);
    Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2, [], 0.5);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);    
end


% get response: direction of MAE
if trialData.validTrial
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
        [keyDown, secs, keyCode] = KbCheck;
        if keyDown
            if keyCode(KbName('LeftArrow'))
                trialData.response = 'LeftArrow';
                trialData.rt = secs - trialData.respScreenTime;
            elseif keyCode(KbName('RightArrow'))
                trialData.response = 'LeftArrow';
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


end
