function screenInfo = openExperiment(monWidth, viewDist, curScreen, useFullScreen)
% screenInfo = openExperiment(monWidth, viewDist, curScreen,useFullScreen)
%Perform a bit of useful housekeeping before opening an experiment.
% Arguments:
%	monWidth ... viewing width of monitor (cm)
%	viewDist ... distance from the center of the subject's eyes to the monitor (cm)
%   curScreen         ... screen number for experiment
%                         default is 0.
%   useFullScreen: Boolean, True will open a full screen window FALSE
%   will open a 500 pixel window. 
%
% returns screenInfo structure with fields:
% bckgnd  - Value of the background level
% curWindow - Pointer to the current window 
% screenRect - the screen rectangle
% monRefresh - monitor refresh rate in Hz.
% ifi        - the interframe interval in seconds
% frameDur   - frame duration in milliseconds
% center     -  coordinates of the monitor center. 
% ppd        - pixels per degree 
% pixPerCm   - pixels per centimeter
% useKbQueue - Determines if program should use KbQueue's to get keyboard

% ---------------
% open the screen
% ---------------

%
% This is a line that is easily skipped/missed 
% Various default setup options, including color as float 0-1;
% 
PsychDefaultSetup(2)

defaultWindowRect = [0 0 500 500];
if nargin < 3
    curScreen = 0;
    windowRect = defaultWindowRect;
elseif nargin < 4
    windowRect = defaultWindowRect;
end
   
if useFullScreen == true
    windowRect = [];
else
    windowRect = defaultWindowRect;
end


%If we're running on a separate monitor assume that we want accurate
%timings, but if we're run on the main desktop diasble synctests i.e. for
%debugging on laptops
if curScreen >0
    Screen('Preference', 'SkipSyncTests', 0);
else
    Screen('Preference', 'SkipSyncTests', 1);
end

Screen('Preference', 'VisualDebugLevel',2);


% Set the background to the background value.
screenInfo.bckgnd = 0.5;
%This uses the new "psychImaging" pipeline. 
[screenInfo.curWindow, screenInfo.screenRect] = PsychImaging('OpenWindow', curScreen, screenInfo.bckgnd,windowRect,32, 2);
screenInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)



%get the refresh rate of the screen
spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.ifi = spf; %putative interframe interval
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;

screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

% determine pixels per degree
% (pix/screen) * ... (screen/rad) * ... rad/deg
screenInfo.ppd = pi * screenInfo.screenRect(3) / atan(monWidth/viewDist/2) / 360;    % pixels per degree

%determine pixels per centimeter
% screenWidth (pixels) / screenWidth (cm) 
screenInfo.pixPerCm = screenInfo.screenRect(3)/monWidth;
% InitializePsychSound
% 
% screenInfo.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);


Screen('TextSize', screenInfo.curWindow, 60);
Screen('BlendFunction', screenInfo.curWindow,  GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%Setup some defaults for keyboard interactions. Can be overridden by your
%experiment.
%Turn off KbQueue's because they can be fragile on untested systems.
%If you need high performance responses turn them on. 
screenInfo.useKbQueue = false;
KbName('UnifyKeyNames');
screenInfo.deviceIndex = [];
ListenChar(2);

