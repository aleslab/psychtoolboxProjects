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
% frameDur   - frame duration in milliseconds
% center     -  coordinates of the monitor center. 
% ppd        - pixels per degree 


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



% Set the background to the background value.
screenInfo.bckgnd = 0.5;
%This uses the new "psychImaging" pipeline. 
[screenInfo.curWindow, screenInfo.screenRect] = PsychImaging('OpenWindow', curScreen, screenInfo.bckgnd,windowRect,32, 2);
screenInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)

%get the refresh rate of the screen
spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;

screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

% determine pixels per degree
% (pix/screen) * ... (screen/rad) * ... rad/deg
screenInfo.ppd = pi * screenInfo.screenRect(3) / atan(monWidth/viewDist/2) / 360;    % pixels per degree

