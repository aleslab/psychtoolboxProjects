function [trialData] = driftSineGratingTrial(expInfo, conditionInfo)

%Trial code for AL's drifting sine wave grating experiments. Run through
%psychMaster and a sine wave grating paradigm file. Some has been adapted
%from psychDemos DriftDemo3.

%% setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window
%this is already in the code somewhere, I should find where and make it
%consistent.

trialData.validTrial = false;
trialData.abortNow   = false;

fixationInfo.fixationType = 'cross';
fixationInfo.responseSquare = 0;
fixationInfo.apetureType = 'frame';
expInfo = drawFixation(expInfo, fixationInfo);

vbl=Screen('Flip', expInfo.curWindow);
Screen('close', expInfo.allTextures); %destroying all of the created
%textures. This is really important because otherwise all of the textures
%that are created are stored, filling the memory and eventually causing a
%huge number of flips to be missed -- giving horrible lag and performance
%issues.

%eye information
IOD = 6; %Interocular distance.
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, expInfo.viewingDistance];
eyeL = [-cycDist, 0, 0]; %left eye's position
eyeR = [cycDist, 0, 0]; %right eye's position in our coordinate system

nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);

velCmPerFrameSection1  = conditionInfo.velocityCmPerSecSection1*expInfo.ifi;
velCmPerFrameSection2  = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;

trialData.flipTimes = NaN(nFramesTotal,1);
frameIdx = 1;

%% trial
%adapted from psychtoolbox demos DriftDemo3
for iFrame = 1:nFramesSection1,
    cyclespersecond = 1; %Speed of grating in cycles per second.
    p = 32; %Spatial period of grating in pixels.
    
    movieDurationSecs=60;   % Abort demo after 60 seconds.
    visiblesize=512;        % Size of the grating image. Needs to be a power of two.
    
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    
    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;
    
    % Calculate parameters of the grating:
    f=1/p; %reciprocal the time period of the wave = frequency (f) of the wave
    fr=f*2*pi;    % frequency in radians.
    
    % Create one single static 1-D grating image.
    % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
    % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
    % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. it is potentially faster on some GPUs.
    x=meshgrid(0:visiblesize-1, 1);
    grating=gray + inc*sin(fr*x);
    
    % Store grating in texture: Set the 'enforcepot' flag to 1 to signal
    % Psychtoolbox that we want a special scrollable power-of-two texture:
    gratingtex=Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
    
    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', expInfo.curWindow);
    waitframes = 1;
    waitduration = waitframes * ifi;
    
    % Translate requested speed of the grating (in cycles per second)
    % into a shift value in "pixels per frame", assuming given
    % waitduration: This is the amount of pixels to shift our srcRect at
    % each redraw:
    shiftperframe= cyclespersecond * p * waitduration;
    
    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl=Screen('Flip', expInfo.curWindow);
    
    % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
    vblendtime = vbl + movieDurationSecs;
    xoffset=0;
    
    % Animationloop:
    while(vbl < vblendtime)
        % Shift the grating by "shiftperframe" pixels per frame:
        xoffset = xoffset - shiftperframe;
        
        % Define shifted srcRect that cuts out the properly shifted rectangular
        % area from the texture:
        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
        
        % Draw grating texture: Only show subarea 'srcRect', center texture in
        % the onscreen window automatically:
        Screen('DrawTexture', expInfo.curWindow, gratingtex, srcRect);
        
        % Flip 'waitframes' monitor refresh intervals after last redraw.
        vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * ifi);
        
    end
    
    %% end section
    expInfo = drawFixation(expInfo, fixationInfo);
    
    Screen('Flip', expInfo.curWindow);
    Screen('close', expInfo.allTextures);
    trialData.flipTimes(frameIdx) = vbl; %another way of keeping track of the
    %flip times and making sure that everything is performing as it should.
    frameIdx = frameIdx+1;
    
end
