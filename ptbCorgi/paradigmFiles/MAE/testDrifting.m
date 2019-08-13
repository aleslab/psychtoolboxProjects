
Screen('Preference', 'SkipSyncTests', 1);

%%%%%%%%%%%%%%%%%
%%% Screen 


% Open a double buffered fullscreen window with a gray background:
PsychDefaultSetup(2)
PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
% PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange', 1);
% [oldmaximumvalue, oldclampcolors, oldapplyToDoubleInputMakeTexture] = Screen('ColorRange', windowPtr [, maximumvalue][, clampcolors][, applyToDoubleInputMakeTexture]);

% Get the list of screens and choose the one with the highest screen number.
screenNumber=max(Screen('Screens'));

% Find the color values which correspond to white and black.
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);

gray=(white+black)/2;
inc=white-gray;

[w, wRect]=PsychImaging('OpenWindow',screenNumber, gray,[0 0 1000 1000]);
% [w, wRect]=PsychImaging('OpenWindow',screenNumber, gray);
[xCenter, yCenter] = RectCenter(wRect);

% Enable alpha blending
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');


%%%%%%%%%%%%%%%%%
%%%% Gratings
texsize=200; % Half-Size of the grating image.
cyclespersecond1 = 2; % speed 
cyclespersecond2 = 2;

% spatial freq of the 2 gratings
f1 = 0.005;
f2 = 0.008;
% direction of the 2 gratings
angle1=0;
angle2=180;
adaptDuration=1; % Adaptation duration 30 s

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
gratingtex1 = Screen('MakeTexture', w, grating1 , [], [], [], [], glsl);
gratingtex2 = Screen('MakeTexture', w, grating2 , [], [], [], [], glsl);

assignin('base','g',grating1)

% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize*2 texsize];
yEcc = 150; % should change that into degrees

%%%%%%%%%%%%%%%%%
%%% timing for presentation
% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', w);
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
vbl = Screen('Flip', w);

vblAdaptTime = vbl + adaptDuration;
i=0;


%%%%%%%%%%%%%%%%%
%%% Adaptation loop: Run for 30 s or keypress.
while (vbl < vblAdaptTime) && ~KbCheck
    
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
    Screen('DrawTexture', w, gratingtex1, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
    Screen('DrawTexture', w, gratingtex2, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);
    
    % just for fun to check
    Screen('DrawTexture', w, gratingtex1, srcRect, CenterRectOnPoint(srcRect,xCenter-200,yCenter+yEcc), angle1, [], 0.5, [], [], [], [0, yoffset1, 0, 0]);
    Screen('DrawTexture', w, gratingtex2, srcRect, CenterRectOnPoint(srcRect,xCenter+200,yCenter+yEcc), angle2, [], 0.5, [], [], [], [0, yoffset2, 0, 0]);

        
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
end

%%%%%%%%%%%%%%%%%
framesPerHalfCycle = 20 ;
testDuration = 10;
moveTest = 2; % motion of the stimulus
Screen('FillRect', w,gray);
vbl = Screen('Flip', w);
vblTestTime = vbl + testDuration;
gratingtest1 = Screen('MakeTexture', w, double(grating1));
gratingtest2 = Screen('MakeTexture', w, double(grating2));

%%% test stimulus (flicker)
while (vbl < vblTestTime) && ~KbCheck
    Screen('DrawTexture', w, gratingtest1, [], CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle1, [], 0.5);
    Screen('DrawTexture', w, gratingtest2, [], CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle2, [], 0.5);
    vbl = Screen('Flip', w, vbl + (framesPerHalfCycle - 0.5) * ifi);
    % move the entire stimulus (overlapping gratings)
    Screen('DrawTexture', w, gratingtest1, [], CenterRectOnPoint(srcRect,xCenter+moveTest,yCenter-yEcc), angle1, [], 0.5);
    Screen('DrawTexture', w, gratingtest2, [], CenterRectOnPoint(srcRect,xCenter+moveTest,yCenter-yEcc), angle2, [], 0.5);
    vbl = Screen('Flip', w, vbl + (framesPerHalfCycle - 0.5) * ifi);    
end

sca;
