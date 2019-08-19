function [trialData] = trial_behaviourMAE_try(expInfo, conditionInfo)
%%% same BlendFunction over the entire program

%%%% contrast ok now but no fixation + pb with borders of the stim (since I
%%%% have removed the +p (+1cycle) when drawing the gratings
%%%% would also be better if the fixation is higher and the stimulus
%%%% presented at the bottom


drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(2)
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;

%%%%%%%%%%%%%%%%%
%%% Screen 
% PsychDefaultSetup(2)
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
% PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange', 1);

% Find the color values which correspond to white and black.
white=WhiteIndex(expInfo.curWindow);
black=BlackIndex(expInfo.curWindow);
gray=(white+black)/2;
inc=white-gray;

% Enable alpha blending
Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
% Screen('BlendFunction', expInfo.curWindow, GL_ONE, GL_ONE);

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
possibleAngles = Shuffle([0 180]); % 0=left, 180=right
angle1=possibleAngles(1);
angle2=possibleAngles(2);
trialData.angle1 = angle1;
trialData.angle2 = angle2;

% Calculate parameters of the grating:
fr1=f1*2*pi;
fr2=f2*2*pi;


% Create gratings:
x = meshgrid(-texsize:texsize, -texsize:texsize);
grating1 = gray + inc*sin(fr1*x);
grating1 = repmat(grating1,[1,1,3]);
grating1(:,:,4) = ones(size(grating1,1));
x2 = meshgrid(-texsize:texsize, -texsize:texsize);
grating2 = gray + inc*sin(fr2*x2);
grating2 = repmat(grating2,[1,1,3]);
grating2(:,:,4) = ones(size(grating2,1))*.5;

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
gratingAdapt1 = Screen('MakeTexture', expInfo.curWindow, grating1 , [], [], [], [], glsl);
gratingAdapt2 = Screen('MakeTexture', expInfo.curWindow, grating2 , [], [], [], [], glsl);

% create gratings for the test
% the 2 gratings are created with the same sin 0 such that it gives a more
% 'edgy' stimulus (which is more natural and that the brain likes)
phase = conditionInfo.testPhase * pi/180; % counterphase
gratingT1 = gray + inc*sin(fr1*x + phase);
gratingT2 = gray + inc*sin(fr2*x2 + phase);
gratingPhaseShift1 = Screen('MakeTexture', expInfo.curWindow, gratingT1);
gratingPhaseShift2 = Screen('MakeTexture', expInfo.curWindow, gratingT2);
gratingtest1 = Screen('MakeTexture', expInfo.curWindow, grating1);
gratingtest2 = Screen('MakeTexture', expInfo.curWindow, grating2);

% assignin('base','g',grating1)

% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize*2 texsize];
yEcc = conditionInfo.yEccentricity * expInfo.ppd;

%%%%%%%%%%%%%%%%%
adaptDuration=30; % Adaptation duration 30 s

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

% %%%% To check that the 2 overlaping gratings have same contrast
% Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1);
%     Screen('DrawTexture', expInfo.curWindow, gratingtest2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2);
%     vbl = Screen('Flip', expInfo.curWindow);
%     imageArray=Screen('GetImage', expInfo.curWindow);
%     figure; plot(imageArray(300,:,1))
%     t=linspace(-2*pi,2*pi,100);
%     figure; plot(t,sin(2*pi*0.13*t+angle1)+sin(2*pi*0.53*t+angle2))  % this is what i should have (add +pi because one grating is reversed = opposite direction)

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
%     Screen('DrawTexture', w, gratingtex2, srcRect, [], angle2, [], 0.5, [], [], [],30 [0, yoffset2, 0, 0]);
    Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
    Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2, [], [], [], [], [], [0, yoffset2, 0, 0]);

%     % just for fun to check
%     Screen('DrawTexture', expInfo.curWindow, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1)-200,expInfo.center(2)+yEcc), angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
%     Screen('DrawTexture', expInfo.curWindow, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,expInfo.center(1)+200,expInfo.center(2)+yEcc), angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);
    if i==10
        imageArray=Screen('GetImage', expInfo.curWindow);
        figure; plot(imageArray(300,:,1))
    end
        
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * ifi);
end

%%%%%%%%%%%%%%%%%
framesPerCycle = 1/conditionInfo.testFreq * round(expInfo.monRefresh);
framesPerHalfCycle = framesPerCycle/2;
drawFixation(expInfo, expInfo.fixationInfo);
vbl = Screen('Flip', expInfo.curWindow);
testStart = vbl;

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
%     vbl = Screen('Flip', expInfo.curWindow, + p vbl + (framesPerHalfCycle - 0.5) * ifi);    
% end



%%% test stimulus 
while ~KbCheck
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('DrawTexture', expInfo.curWindow, gratingtest1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1);
    Screen('DrawTexture', expInfo.curWindow, gratingtest2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);
    % move the entire stimulus (overlapping gratings)
    drawFixation(expInfo, expInfo.fixationInfo);
    Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift1, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle1);
    Screen('DrawTexture', expInfo.curWindow, gratingPhaseShift2, [], CenterRectOnPoint(srcRect,expInfo.center(1),expInfo.center(2)-yEcc), angle2);
    vbl = Screen('Flip', expInfo.curWindow, vbl + (framesPerHalfCycle - 0.5) * ifi);    
end


% get response: direction of MAE
if trialData.validTrial
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
        [keyDown, secs, keyCode] = KbCheck;
        if keyDown
            if keyCode(KbName('LeftArrow'))
                trialData.response = 'LeftArrow';
                trialData.rt = secs - testStart;
            elseif keyCode(KbName('RightArrow'))
                trialData.response = 'RightArrow';
                trialData.rt = secs - testStart;
            elseif keyCode(KbName('DownArrow'))
                trialData.response = 'DownArrow';
                trialData.rt = secs - testStart;
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
