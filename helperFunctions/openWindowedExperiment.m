function screenInfo = openWindowedExperiment(monWidth, viewDist, curScreen)
% screenInfo = openExperiment(monWidth, viewDist, curScreen)
% Arguments:
%	monWidth ... viewing width of monitor (cm)
%	viewDist     ... distance from the center of the subject's eyes to
%	the monitor (cm)
%   curScreen         ... screen number for experiment
%                         default is 0.
% Sets the random number generator, opens the screen, gets the refresh
% rate, determines the center and ppd, and stops the update process 
%
% Original from MKMK July 2006
% Modified by Justin Ales


%ACK!! This is out of date for new matlab!
%Commenting out so it doesn't bite later. 
% 1. SEED RANDOM NUMBER GENERATOR
%
% screenInfo.rseed = [];
% rseed = sum(100*clock);
% rand('state',rseed);
%screenInfo.rseed = sum(100*clock);
%rand('state',screenInfo.rseed);

% ---------------
% open the screen
% ---------------

%
% This is a line that is easily skipped/missed 
% Various default setup options, including color as float 0-1;
% 
PsychDefaultSetup(2)

if nargin < 3
    curScreen = 0;
end


% Set the background to the background value.
screenInfo.bckgnd = 0.5;
%This uses the new "psychImaging" pipeline. 
[screenInfo.curWindow, screenInfo.screenRect] = PsychImaging('OpenWindow', curScreen, screenInfo.bckgnd,[0 0 500 500],32, 2);
screenInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)

%get the refresh rate of the screen
spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;

screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

% determine pixels per degree
% (pix/screen) * ... (screen/rad) * ... rad/deg
screenInfo.ppd = pi * screenInfo.screenRect(3) / atan(monWidth/viewDist/2) / 360;    % pixels per degree

