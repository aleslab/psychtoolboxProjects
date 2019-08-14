
%%%
% test if f is the velocity or the temporal frequency of the grating
% for that present 3 gratings:
% 1. 3 c/deg at cyclespersecond=5Hz (presented in the middle)
% 2. 6 c/deg at cyclespersecond=5Hz (top)
% 3. 6 c/deg at cyclespersecond=10 Hz (bottom)
% if cyclespersecond is velocity then perceived velocity is the same for 1 and 2
% if cyclespersecond is temporal frequency then perceived velocity is the same for 1 and 3

%%%%% Observation!!
%%%%% 1 and 3 have the same velocity (if you follow a point on 1 it moves
%%%%% as fast as on 3) 
%%% cyclespersecond is the temporal frequency!!!!!



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
texsize=150; % Half-Size of the grating image.
cyclespersecond1 = 5; 
cyclespersecond2 = 5;
cyclespersecond3 = 10;


% spatial freq 
ppd = 46; % around that on my mac
f1 = 3/ppd;
f2 = 6/ppd;
f3 = 6/ppd;
% direction of the 2 gratings
angle1=0;
angle2=0;
angle3=0;

% Calculate parameters of the grating:
p1=ceil(1/f1); % pixels/cycle, rounded up.
p2=ceil(1/f2);
p3=ceil(1/f3);
fr1=f1*2*pi;
fr2=f2*2*pi;
fr3=f3*2*pi;

% Create gratings:
x = meshgrid(-texsize:texsize + p1, -texsize:texsize);
grating1 = gray + inc*cos(fr1*x);
x2 = meshgrid(-texsize:texsize + p2, -texsize:texsize);
grating2 = gray + inc*cos(fr2*x2);
x3 = meshgrid(-texsize:texsize + p3, -texsize:texsize);
grating3 = gray + inc*cos(fr3*x3);

% Store alpha-masked grating in texture and attach the special 'glsl'
% texture shader to it:
gratingtex1 = Screen('MakeTexture', w, grating1 , [], [], [], [], glsl);
gratingtex2 = Screen('MakeTexture', w, grating2 , [], [], [], [], glsl);
gratingtex3 = Screen('MakeTexture', w, grating3 , [], [], [], [], glsl);


% Definition of the drawn source rectangle on the screen:
srcRect=[0 0 texsize*2 texsize];

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
p3 = 1/f3; % pixels/cycle

% Translate requested speed of the gratings (in cycles per second) into
% a shift value in "pixels per frame", assuming given waitduration:
shiftperframe1 = cyclespersecond1 * p1 * waitduration;
shiftperframe2 = cyclespersecond2 * p2 * waitduration;
shiftperframe3 = cyclespersecond3 * p3 * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl = Screen('Flip', w);

i=0;

%%%%%%%%%%%%%%%%%
%%% Adaptation loop: Run for 30 s or keypress.
while ~KbCheck
    
    % Shift the grating by "shiftperframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    yoffset1 = mod(i*shiftperframe1,p1);
    yoffset2 = mod(i*shiftperframe2,p2);
    yoffset3 = mod(i*shiftperframe3,p3);
    i=i+1;
       
    % just for fun to check
    Screen('DrawTexture', w, gratingtex1, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter), [], [], [], [], [], [], [0, yoffset1, 0, 0]);
    Screen('DrawTexture', w, gratingtex2, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter-150), [], [], [], [], [], [], [0, yoffset2, 0, 0]);
    Screen('DrawTexture', w, gratingtex3, srcRect, CenterRectOnPoint(srcRect,xCenter,yCenter+150), [], [], [], [], [], [], [0, yoffset3, 0, 0]);

        
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
end

sca;
