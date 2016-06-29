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

%% creating an initial texture
p = 32; %period
f = 1/p; %frequency
fr = 2*pi*f; %angular frequency in radians
x = [0:1:511];

%% trial

for iFrame = 1:nFramesPreStim %for the frames before the stimulus starts to move
    
%     grating = sin(fr*x);
%     gratingTex = Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
%     Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
    Screen('close', expInfo.allTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
end

for iFrame = 1:nFramesSection1
     
%     grating = sin(fr*x);
%     gratingTex = Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
%     Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
    Screen('close', expInfo.allTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
end

for iFrame = 1:nFramesSection2
    
%     grating = sin(fr*x);
%     gratingTex = Screen('MakeTexture', expInfo.curWindow, grating, [], 1);
%     Screen('DrawTexture', expInfo.curWindow, gratingTex, srcRect);
    expInfo = drawFixation(expInfo, fixationInfo);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
    Screen('close', expInfo.allTextures);
    trialData.flipTimes(frameIdx) = vbl;
    frameIdx = frameIdx+1;
end

expInfo = drawFixation(expInfo, fixationInfo);

Screen('Flip', expInfo.curWindow);
Screen('close', expInfo.allTextures);
trialData.flipTimes(frameIdx) = vbl; %another way of keeping track of the
%flip times and making sure that everything is performing as it should.
frameIdx = frameIdx+1;

end
