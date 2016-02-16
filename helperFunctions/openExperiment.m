function expInfo = openExperiment( expInfo)
% expInfo = openExperiment(expInfo.monitorWidth, expInfo.viewingDistance, expInfo.screenNum,expInfo.useFullScreen)
%Perform a bit of useful housekeeping before opening an experiment.
% Arguments:
%	expInfo.monitorWidth     - viewing width of monitor (cm)
%	expInfo.viewingDistance  - distance from participant to monitor (cm)
%   expInfo.screenNum        - screen number for experiment (defaults to  max)
%   expInfo.stereoMode       -                    
%   expInfo.useFullScreen: Boolean, True will open a full screen window FALSE
%   will open a 500 pixel window. 
%
% returns expInfo structure with fields:
% bckgnd  - Value of the background level
% curWindow - Pointer to the current window 
% screenRect - the screen rectangle
% monRefresh - monitor refresh rate in Hz.
% ifi        - the interframe interval in seconds
% frameDur   - frame duration in milliseconds
% center     -  coordinates of the monitor center. 
% ppd        - pixels per degree 
% pixPerCm   - pixels per centimeter
% useKbQueue - Defaults to false. Override if needed 
%            - Determines if program should use KbQueue's to get keyboard

% ---------------
% open the screen
% ---------------

%
% This is a line that is easily skipped/missed but is important
% Various default setup options, including color as float 0-1;
% 
PsychDefaultSetup(2)

defaultWindowRect = [0 0 720 720];

if nargin==0 || isempty(expInfo)
    expInfo = struct();
end

%By default choose an external monitor if connected.
if ~isfield(expInfo,'screenNum')
    expInfo.screenNum = max(Screen('Screens'));  
end

%Default is mono mode
if ~isfield(expInfo,'stereoMode')
    expInfo.stereoMode = 0;
end

%Default viewing distance 
if ~isfield(expInfo,'viewingDistance')
    expInfo.viewingDistance = 57;
end

%Default to testing in a small window 
if ~isfield(expInfo,'useFullScreen')
    if expInfo.screenNum >0
        expInfo.useFullScreen = true;
    else
        expInfo.useFullScreen = false;
    end
end



%This is not always a reliable way to get screen width.  MEASURE IT!!
%But it's the best guess we can do.
if ~isfield(expInfo,'monitorWidth')
    [w, h]=Screen('DisplaySize',expInfo.screenNum)
    expInfo.monitorWidth = w/10; %Convert to cm from mm
end

   
if expInfo.useFullScreen == true
    windowRect = [];
else
    windowRect = defaultWindowRect;
end


%If we're running on a separate monitor assume that we want accurate
%timings, but if we're run on the main desktop diasble synctests i.e. for
%debugging on laptops
if expInfo.screenNum >0
    Screen('Preference', 'SkipSyncTests', 0);
    
else
    Screen('Preference', 'SkipSyncTests', 2);
end

Screen('Preference', 'VisualDebugLevel',2);


% Set the background to the background value.
expInfo.bckgnd = 0.5;
%This uses the new "psychImaging" pipeline. 
[expInfo.curWindow, expInfo.screenRect] = PsychImaging('OpenWindow', expInfo.screenNum, expInfo.bckgnd,windowRect,[],[], expInfo.stereoMode);
expInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)

if isfield(expInfo,'gammaTable')
    [oldClut sucess]=Screen('LoadNormalizedGammaTable',expInfo.curWindow,expInfo.gammaTable);
else
    oldClut = LoadIdentityClut(expInfo.curWindow);
    [gammaTable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable',expInfo.curWindow);
    expInfo.gammaTable = gammaTable;
end


%get the refresh rate of the screen
spf =Screen('GetFlipInterval', expInfo.curWindow);      % seconds per frame
expInfo.ifi = spf; %putative interframe interval
expInfo.monRefresh = 1/spf;    % frames per second
expInfo.frameDur = 1000/expInfo.monRefresh;

expInfo.center = [expInfo.screenRect(3) expInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

[pixelWidth, pixelHeight]=Screen('WindowSize', expInfo.screenNum);


% determine pixels per degree
% (pix/screen) * ... (screen/rad) * ... rad/deg
expInfo.ppd = pi * pixelWidth / atan(expInfo.monitorWidth/expInfo.viewingDistance/2) / 360;    % pixels per degree
%determine pixels per centimeter
% screenWidth (pixels) / screenWidth (cm)
expInfo.pixPerCm = pixelWidth/expInfo.monitorWidth;



% InitializePsychSound
% 
% expInfo.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);


Screen('TextSize', expInfo.curWindow, 60);
Screen('BlendFunction', expInfo.curWindow,  GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%Setup some defaults for keyboard interactions. Can be overridden by your
%experiment.
%Turn off KbQueue's because they can be fragile on untested systems.
%If you need high performance responses turn them on. 
expInfo.useKbQueue = false;
KbName('UnifyKeyNames');
expInfo.deviceIndex = [];
ListenChar(0);

