%
% Simple script for testing a looming grating experiment.
%
%We enclose everything in a try-catch statement because psychtoolbox
%doesn't automatically clear if there's a programming error.
%The try/catch will gracefully fail on an error
try
    
    %initialize the screen
    %for this simple test script I'm turning off some critical tests
    %because we just want to get a workable program, we can optimize the
    %sytem later.
    Screen('Preference', 'SkipSyncTests', 1);
    
    %Setup some parameters so we can put things into useful coordinates.
    screenWidthCm = 34;
    screenDistanceCm = 50;
    screenNumber = 0;
    
    %I find a windowed version of the experiment is easier to get working
    %and play with.
    screenInfo = openWindowedExperiment(screenWidthCm,screenDistanceCm,screenNumber);
    
    %Using the new "procedural" mechanisms that have the graphics card
    %calculate the stimulus instead of us.  Allows for for rapid 
    %See driftDemo4.m
    %This bit is a little crazy but what the hell. I'm modifying a bit of
    %code I have laying around. Saves me time and shows a modern animation
    %method.  

    
    % Build a procedural  texture  with a support of tw x th
    % pixels, and a RGB color offset of 0.5 -- a 50% gray.
    % Initial stimulus params for the patch:
    res = 1*[128 128];
    phase = 90;
    sc = 5.0;
    %Frequency in cycles/degree; Need it in cycles/pixel. So by dimensional
    %analysis:
    %(cyc/d) / (pix/d) = cycl/pix
    startingFreq = 2/screenInfo.ppd;
    endingFreq   = .1/screenInfo.ppd;
    tilt = 0;
    contrast = .250; %!!! warning this never means what you think it does. 
    aspectratio = 1.0;
    tw = res(1);
    th = res(2);
    nonsymmetric = 0;
    
    %Create a sine wave grating
    stimTex = CreateProceduralSineGrating(screenInfo.curWindow, tw, th,  [0.5 0.5 0.5 0.0]);
    
    %If we want a gabor:
    %stimTex = CreateProceduralGabor(screenInfo.curWindow, tw, th, nonsymmetric, [0.5 0.5 0.5 0.0]);
    
    %Specifying duration in milliseconds is inaccurate because we can only
    %present things at an integer multiple of frames.
    trialDuration = 10000; %In milliseconds. 
    %Here we figure out what we'll actually display.
    nFrames = round(trialDuration/screenInfo.frameDur);
    
    %Warning linspace is wrong for a real loom. 
    freqList = linspace(startingFreq,endingFreq,nFrames);
    
    keepShowing= true;
    condInfo = [];
    position = nan(nFrames,2);
    velocity = nan(nFrames,2);
    mousePos = nan(nFrames,2);
    
    
    for iFrame=1:nFrames,
        
        freq = freqList(iFrame);
        %Heres a wacky line, This sets the focus of expansion of the
        %grating.  I'm tempted to leave this as an excercise for the
        %reader. But I wont:
        %1) the origin of the texture defaults to a corner not the center
        %so we need  to recenter to tw/2 (the center of the
        %texture)
        %2) The drawing code has phase in "degrees" I need it in radians
        %so I use a rad2deg 
        %3) algebra: grating = sin(2*pi*freq*x);
        %we change x to (x-tw/2)
        %sin(2*pi*freq*(x-tw/2)) = sin(2*pi*freq*x -
        %2*pi*freq*(tw/2))
        phase = -rad2deg(2*pi*freq*(tw/2));
        % Draw the Gabor patch: We simply draw the procedural texture as any other
        % texture via 'DrawTexture', but provide the parameters for the gabor as
        % optional 'auxParameters'.
        %Screen('DrawTexture', screenInfo.curWindow, stimTex, [], [], 90+tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
        % Draw a sine wave grating, the procedural parameters are slightly
        % different from the gabor:
        Screen('DrawTexture', screenInfo.curWindow, stimTex, [], [], 90+tilt, [], [], [], [], kPsychDontDoRotation, [phase, freq, contrast, 0]);
        Screen('flip',screenInfo.curWindow);

        
        [keyIsDown,secs, keyCode, deltaSecs] = KbCheck([]);
        
        
           if keyCode(41) %press escape to quit
             break;  
           end
    end
    
    
    closeExperiment;
    
    
catch
    disp('caught')
    errorMsg = lasterror;
    %screenInfo
    closeExperiment;
    error(errorMsg.message)
    %closeScreen(screenInfo.curWindow, screenInfo.oldclut)
end;

