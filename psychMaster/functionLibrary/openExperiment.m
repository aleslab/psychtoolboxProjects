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



%Sometimes we lose keyboard input, resetting PsychHID seems to help
%Psychtoolbox uses a lot of persistent data and mex files in memory.
%Should consider if clear all should be done.  A clear all will clear all
%that stuff.  But has implications for anything that calls this function.
%THerefore, I think the nuclear clear all should be elsewhere and carefully
%considered/tested.
clear PsychHID;
clear KbCheck;

%Close psychPortAudio handles if left open by crash
PsychPortAudio('Close');
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

%If a window shielding level is set use it
%This setting is used to make the window semi transparent to facilitate
%development of stimuli.
if isfield(expInfo,'windowShieldingLevel')
    Screen('Preference', 'WindowShieldingLevel', expInfo.windowShieldingLevel);
else    
    Screen('Preference', 'WindowShieldingLevel', 2000);
end

%Default is mono mode
if ~isfield(expInfo,'stereoMode')
    expInfo.stereoMode = 0;
end

%Check if a specific resolution has been requested
if ~isfield(expInfo,'requestedResolution') || isempty(expInfo.requestedResolution)

    %If the user hasn't requested a resolution let's see if the resolution
    %preference has been set. 
    
    if ispref('ptbCorgi','screenResolution')
        requestedResolution = getpref('ptbCorgi','resolution');
    else    
    %If nothing is set just use the current resolution. 
    requestedResolution = Screen('resolution',expInfo.screenNum);
    end
    
else     %Now check what is requested.

    resFieldList = {'width','height','pixelSize','hz'};
    resFieldExist = isfield( expInfo.requestedResolution,resFieldList);
    
    for iField = 1:length(resFieldList)
        
        %If the field doesn't exist set it to empty.
        if ~resFieldExist(iField)
            expInfo.requestedResolution.(resFieldList{iField}) = [];
        end
    end
                   
    requestedResolution = NearestResolution(expInfo.screenNum,...
        expInfo.requestedResolution.width,expInfo.requestedResolution.height,...
        expInfo.requestedResolution.hz,expInfo.requestedResolution.pixelSize);
    
end

currentRes =Screen('resolution',expInfo.screenNum);

%If the current resolution is different from what we want change the
%resolution.
if ~isequaln(currentRes,requestedResolution)
    oldres =SetResolution(expInfo.screenNum,requestedResolution);
end


%Default viewing distance
if ~isfield(expInfo,'viewingDistance')
    expInfo.viewingDistance = 57;
end

%Default fully randomize everything
if ~isfield(expInfo, 'trialRandomization')

    expInfo.trialRandomization.type = 'random';
    
    %If old type filed is set use that. 
     if isfield(expInfo,'randomizationType')
         expInfo.trialRandomization.type =  expInfo.randomizationType;
     end
%     
%     %Default randomizationOptions is empty
%     if ~isfield(expInfo,'randomizationOptions')
%         expInfo.randomizationOptions = [];
%     end
    

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
    [w, h]=Screen('DisplaySize',expInfo.screenNum);
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
Screen('Preference', 'Verbosity',3);


if ~isfield(expInfo,'useBitsSharp')
    expInfo.useBitsSharp = false;
end

if ~isfield(expInfo,'enableTriggers')
    expInfo.enableTriggers = false;
end

%Now setup bitssharp if requested
if  expInfo.useBitsSharp
    %Setup taken from BitsPlusPlusIdentityClutTest
     % Setup imaging pipeline:
    PsychImaging('PrepareConfiguration');

    % Require a 32 bpc float framebuffer: This would be the default anyway, but
    % just here to be explicit about it:
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');

%     
    % Use Mono++ mode with overlay:
    PsychImaging('AddTask', 'General', 'EnableBits++Mono++OutputWithOverlay');

    
    %     % Make sure we run with our default color correction mode for this test:
    %     % 'ClampOnly' is the default, but we set it here explicitely, so no state
    %     % from previously running scripts can bleed through:
    %     PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'ClampOnly');
    % Want to have simple power-law gamma correction of stims: We choose the
    % method here. After opening the onscreen window, we can set and change
    % encoding gamma via PsychColorCorrection() function...
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    
    %Setup trigger values
    if expInfo.enableTriggers
        expInfo.triggerInfo = ptbCorgiTriggerDefault(expInfo);
    end
    
end


% Set the background to the background value.
expInfo.bckgnd = 0.5;
%This uses the new "psychImaging" pipeline.
[expInfo.curWindow, expInfo.screenRect] = PsychImaging('OpenWindow', expInfo.screenNum, expInfo.bckgnd,windowRect,[],[], expInfo.stereoMode);

%If we're using a bitsSharp mode we also have an overlay window.
if expInfo.useBitsSharp
    expInfo.curOverlay = PsychImaging('GetOverlayWindow', expInfo.curWindow);
else %If we're not using a bitSharp mode we point the overlay to the current window. 
    expInfo.curOverlay = expInfo.curWindow;
end

%Gather information about the system
expInfo.modeInfo =Screen('Resolution', expInfo.screenNum);
expInfo.windowInfo = Screen('GetWindowInfo', expInfo.curWindow);

%If we're running full screen lets hide the mouse cursor from view.
%This should just hide the cursor on the experiment monitor but under OS/X
%10.9-10.10 appears to hide it on all screens. 
if expInfo.useFullScreen == true
    HideCursor(expInfo.screenNum);
end

%Verify size calibration video mode:
if isfield(expInfo,'sizeCalibInfo')
    %First check if the calibration was done for the current system.
    [ isCorrectSystem, msg ] = checkIfCalibrationIsForThisSystem( expInfo, expInfo.sizeCalibInfo );
    
    if ~isCorrectSystem
         disp('---> Size calibration was for a different system:');
         disp(msg);
         error('Cannot contiue due to size calibration mismatch with system');
    end
    %
    if ~isequal(expInfo.sizeCalibInfo.modeInfo,expInfo.modeInfo)
        disp('---> Size calibration was for a different video mode')
        disp('Current Mode: ')
        expInfo.modeInfo
        disp('Calibration for: ');
        expInfo.sizeCalibInfo.modeInfo
        error('Cannot continue due to size calibration mismatch to current video mode')
    end
    
    
end

if isfield(expInfo,'gammaTable')
    
    %Verifiy calibration is for the current video mode:
    if ~isequal(expInfo.lumCalibInfo.modeInfo,expInfo.modeInfo)
        disp('---> Luminance calibration was for a different video mode')
        disp('Current Mode: ')
        expInfo.modeInfo
        disp('Calibration for: ');
        expInfo.lumCalibInfo.modeInfo
        error('Cannot continue due to luminance calibration mismatch to current video mode')
    end
    
    if expInfo.useBitsSharp
        %If we are using the bits sharp in mono++ mode
        % Set encoding gamma: It is 1/gamma to compensate for decoding gamma...
        PsychColorCorrection('SetEncodingGamma', expInfo.curWindow, 1/expInfo.lumCalibInfo.gammaParams);        
    else
        BackupCluts;
        [oldClut sucess]=Screen('LoadNormalizedGammaTable',expInfo.curWindow,expInfo.gammaTable);
    end
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


%determine pixels per centimeter
% screenWidth (pixels) / screenWidth (cm)
expInfo.pixPerCm = pixelWidth/expInfo.monitorWidth;

% determine pixels per degree pix/screen X (screen/deg )
% Note: We are using a convienient assumption that pixPerDegree is linear.
% But it is not actually linear, because screens are flat. So the actual
% pixPerDegree actually depends on monitor geometry and where eyes are
% fixated and where the stimulus is drawn. But for convience we're just
% going to assume linear. This get's us close enough for normal monitors
% and averages the derivative between the fixation and the edge of
% the monitor. But if accurate visual angles at large eccentricities are
% important you'll need use pixPerDegAtEdge.
%
% calculate pixPerDeg by assuming fixation is in the center. And averaging
% the the number of pixels per degree from the fixation to the edge:
% 
% pixels/degree = (pixels/(halfMonitorWidth Cm) X  (halfMonitorWidth Cm/degrees)
expInfo.pixPerDeg = (pixelWidth/2)  *   (1/atand( (expInfo.monitorWidth/2) / expInfo.viewingDistance  ));

delta = .01; %Calculate the derivative for a .1 mm change;

% pixels/degree = (pixels/(1 cm) * ((1 cm)/deg
expInfo.pixPerDegAtCenter = (expInfo.pixPerCm) / (atand(  delta/ expInfo.viewingDistance )./delta);

% Here we will calculate cm/deg by taking the difference in degrees for a
% a 1 cm change in location at the monitor edge assuming fronto-parallel
% monitor with participant seated at center of monitor:
deg1 = atand( ((expInfo.monitorWidth/2)-delta) / expInfo.viewingDistance );
deg2 = atand( (expInfo.monitorWidth/2) / expInfo.viewingDistance );
degPerCm = (deg2-deg1)/delta;
expInfo.pixPerDegAtEdge = (expInfo.pixPerCm) / (degPerCm);

%Old calculation. A little dense so unpacked above for clarity
% (pix/screen) X (screen/rad) X rad/deg
%expInfo.pixPerDeg = pi * pixelWidth / atan(expInfo.monitorWidth/expInfo.viewingDistance/2) / 360;    % pixels per degree
%ppd is deprecated. Included for backwards compatibility.
expInfo.ppd = pi * pixelWidth / atan(expInfo.monitorWidth/expInfo.viewingDistance/2) / 360;    % pixels per degree

[pixelWidthWin, pixelHeightWin] = Screen('WindowSize', expInfo.curWindow);

expInfo.windowSizePixels = [pixelWidthWin, pixelHeightWin];


%For stereo modes default mode has a fixation cross and a frame to aid
%holding fixation.
if ~isfield(expInfo,'fixationInfo')    
    if expInfo.stereoMode ~=0
        expInfo.fixationInfo(1).type = 'cross';
        expInfo.fixationInfo(2).type = 'noiseFrame';
        expInfo.fixationInfo(2).size = 100/expInfo.ppd;
    else
        expInfo.fixationInfo(1).type = '';
    end
end

%Figure out a better way of handling turning on/off audio.
if ~isfield(expInfo,'enableAudio')
    expInfo.enableAudio = true;
end

%TODO: clean up this code. 
if expInfo.enableAudio
    InitializePsychSound
    
    %Basic audio information for interval beeps and audio
    %feedback
    
    audioInfo.nOutputChannels = 2;
    audioInfo.samplingFreq = 48000;
    audioInfo.nReps = 1;
    audioInfo.beepLength = 0.25; %in seconds
    audioInfo.beepFreq = 500;
    audioInfo.startCue = 0; %starts immediately on call
    audioInfo.ibi = 0.05; %inter-beep interval; only used for the second interval
    audioInfo.pahandle = [];%PsychPortAudio('Open', [], 1, 1, audioInfo.samplingFreq, audioInfo.nOutputChannels);
    audioInfo.postFeedbackPause = 0.25;
    thisBeep = MakeBeep(500, audioInfo.beepLength, audioInfo.samplingFreq);
    audioInfo.intervalBeep = repmat(thisBeep,audioInfo.nOutputChannels,1);
    %the beeps that are used for correct or incorrect responses if
    %audio feedback is turned on
    thisBeep = MakeBeep(750, audioInfo.beepLength, audioInfo.samplingFreq);    
    audioInfo.correctSnd = repmat(thisBeep,audioInfo.nOutputChannels,1);
    thisBeep = MakeBeep(250, audioInfo.beepLength, audioInfo.samplingFreq);
    audioInfo.incorrectSnd = repmat(thisBeep,audioInfo.nOutputChannels,1);
    
             
    
    audioInfo.pahandle = PsychPortAudio('Open', [], [], 0, [], 2);
    expInfo.audioInfo = audioInfo;
    
end


%Set default font size.
Screen('TextSize', expInfo.curWindow, 60);
Screen('BlendFunction', expInfo.curWindow,  GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);



%Setup some defaults for keyboard interactions. 
%Turn off KbQueue's because they can be fragile on untested systems. And
%the code hasn't fully implemented them. 
%If you need high performance responses turn them on. But be careful and
%read the help and the help for ListenChar
expInfo.useKbQueue = false;
KbName('UnifyKeyNames');
%-3 Merges all connected keypads and keyboards for KbCheck()
%Negative numbers mean use default keyboard for kbQueueXXX()
expInfo.inputDeviceNumber = -3;
expInfo.deviceIndex = expInfo.inputDeviceNumber; %For old fieldname that wasn't clear

%If we're in full screen mode we'll disable keypress mirroring to the
%matlab window.
if expInfo.useFullScreen
    
    if expInfo.useKbQueue
        %If using KbQueues need to disable GetChar and use flag -1 to
        %supress inp
        ListenChar(0);
        ListenChar(-1);
        expInfo.inputDeviceNumber = -3; %Negative numbers mean use default for kbQueue
    else
        ListenChar(2); %disable echoing keypress to matlab window
        expInfo.inputDeviceNumber = -3; 
    end
else
    


%If using the powermate find it's handle. 
if isfield(expInfo,'enablePowermate') && expInfo.enablePowermate
   expInfo.powermateId = PsychPowerMate('Open');
end


end
