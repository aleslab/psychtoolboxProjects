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
Screen('BlendFunction', w, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
% Screen('BlendFunction', expInfo.curWindow, GL_ONE, GL_ONE);

% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');



%%%% Gratings
ppd = 46;
stimSize = 16;
texsize = stimSize*ppd; % Size of the grating image.
cyclespersecond1 = 85/18; % temporal frequency (related to velocity)
cyclespersecond2 = cyclespersecond1; % same for both gratings

% spatial freq of the 2 gratings
f1 = 0.5/ppd; % cycle/deg
f2 = 2/ppd;
% direction of the 2 gratings
angle1 = 180;
angle2 = 0;

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

gratingAdapt1 = Screen('MakeTexture', w, grating1 , [], [], [], [], glsl);
gratingAdapt2 = Screen('MakeTexture', w, grating2 , [], [], [], [], glsl);
    
% create gratings for the test
% the 2 gratings are created with the same sin 0 such that it gives a more
% 'edgy' stimulus (which is more natural and that the brain likes)
phase = 90 * pi/180; % 180=counterphase
gratingT1 = gray + inc*sin(fr1*x + phase);
gratingT2 = gray + inc*sin(fr2*x2 + phase);
% add alpha column
gratingT1 = repmat(gratingT1,[1,1,3]);
gratingT2 = repmat(gratingT2,[1,1,3]);
gratingT1(:,:,4) = ones(size(gratingT1,1));
gratingT2(:,:,4) = ones(size(gratingT2,1))*.5;
% make texture
gratingPhaseShift1 = Screen('MakeTexture', w, gratingT1);
gratingPhaseShift2 = Screen('MakeTexture', w, gratingT2);
gratingtest1 = Screen('MakeTexture', w, grating1);
gratingtest2 = Screen('MakeTexture', w, grating2);


% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize texsize/2];
yEcc = 3 * ppd;



Screen('DrawTexture', w, gratingtest1, [], CenterRectOnPoint(srcRect,xCenter,yCenter+yEcc), angle1);
Screen('DrawTexture', w, gratingAdapt1, [], CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle1);
vbl = Screen('Flip', w);
  
yoffset1
Screen('DrawTexture', w, gratingAdapt1, [], CenterRectOnPoint(srcRect,xCenter,yCenter-yEcc), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
Screen('DrawTexture', w, gratingAdapt1, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter+yEcc), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
Screen('DrawTexture', w, gratingAdapt1, srcRect, [], angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
vbl = Screen('Flip', w);
Screen('DrawTexture', w, gratingAdapt2, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter+yEcc), angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
Screen('DrawTexture', w, gratingAdapt2, srcRect, [], angle1, [], [], [], [], [], [0, yoffset1, 0, 0]);
vbl = Screen('Flip', w);
