function [trialData] = driftSineGratingTrial(expInfo, conditionInfo)

%Trial code for AL's drifting sine wave grating experiments. Run through
%psychMaster and a sine wave grating paradigm file. Some has been adapted
%from psychDemos DriftDemo3.
%
%Draws a sine wave grating that drifts towards the right of the screen in a
%similar way to how the sets of lines move when programmed to move
%laterally in MoveLineTrial (e.g. in the combined_retinal_lateral
%condition).


%% setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window

trialData.validTrial = false;
trialData.abortNow   = false;

fixationInfo.fixationType = 'cross';
fixationInfo.responseSquare = 0;
fixationInfo.apetureType = 'frame';
expInfo = drawFixation(expInfo, fixationInfo);

vbl=Screen('Flip', expInfo.curWindow);
Screen('close', expInfo.fixationTextures); %destroying all of the created
%textures from drawFixation (the apeture frame). This is really important
%because otherwise all of the textures that are created are stored, filling
%the memory and eventually causing ahuge number of flips to be missed --
%giving horrible lag and performance issues.

%the number of frames for each section of an interval
nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;

%defining the velocity of both sections of an interval in cm/frame and pixels/frame
velCmPerFrameSection1  = conditionInfo.velocityCmPerSecSection1*expInfo.ifi;
velPixPerFrameSection1 = velCmPerFrameSection1*expInfo.pixPerCm;

velCmPerFrameSection2  = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;
velPixPerFrameSection2 = velCmPerFrameSection2*expInfo.pixPerCm;

trialData.flipTimes = NaN(nFramesTotal,1);
frameIdx = 1;

pixPerCyc = 64; %Spatial period of grating in pixels; pixels per cycle.
%A bigger number means bigger bands of light and dark contrast when the
%sine wave grating is drawn.

visiblesize = 256; % Size of the grating image. Needs to be a power of two
%or the grating isn't drawn properly.

xoffset = 0;

white = 1;
black = 0;
gray = 0.5;
contrastIncrement = white-gray;

% Calculate parameters of the grating:
freq = 1/pixPerCyc; %reciprocal the time period of the wave = frequency (f) of the wave
freqRad = freq*2*pi;    % frequency in radians.

% Create one single static 1-D grating image.
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
x=meshgrid(0:visiblesize-1, 1);
grating=gray + contrastIncrement*sin(freqRad*x);

%% trial
%adapted from psychtoolbox demos DriftDemo3
for iFrame = 1:nFramesPreStim
    gratingTex=Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
    
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    Screen('close', gratingTex);
    Screen('close', expInfo.fixationTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
end

for iFrame = 1:nFramesSection1
    
    gratingTex=Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
    
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    Screen('close', gratingTex);
    Screen('close', expInfo.fixationTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    xoffset = xoffset - velPixPerFrameSection1;
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
    
end

for iFrame = 1:nFramesSection2
    
    gratingTex=Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
    
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
    Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    Screen('close', gratingTex);
    Screen('close', expInfo.fixationTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
    
    xoffset = xoffset - velPixPerFrameSection2;
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
    
end

%% end section
expInfo = drawFixation(expInfo, fixationInfo);

Screen('Flip', expInfo.curWindow);
Screen('close', gratingTex);
Screen('close', expInfo.fixationTextures);

trialData.flipTimes(frameIdx) = vbl; %another way of keeping track of the
%flip times and making sure that everything is performing as it should.
frameIdx = frameIdx+1;

end
