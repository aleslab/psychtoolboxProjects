function [trialData] = MoveLineTrial(expInfo, conditionInfo)
%Trial code for AL's moving line experiments. Run through psychMaster and
%psychParadigm files.
%
%cd = binocular only; single vertical line moving in depth at a rate that
%is accelerating on the retina.
%
%lateralCd = one eye's image from the combined condition projected to both
%eyes. A single vertical line that accelerates on the retina but moves
%laterally. Left eye's image is always used.
%
%combined = binocular + looming information; two vertical lines moving in
%depth at an accelerating rate on the retina. The lines move further apart
%as they approach the observer.
%
%combined_retinal_lateral = two vertical lines moving at a constant retinal speed
%laterally across the screen. Contains no looming or binocular depth
%information. Move from left to right.
%
%combined_retinal_depth = two vertical lines moving at constant retinal
%speed in depth. This makes it an unrealistic stimulus that does not look
%like something approaching through depth at a constant speed would.
%Contains both binocular and size change information (but not looming
%because no acceleration for the size change.
%
%lateralCombined = one eye's image from the combined condition projected to
%both eyes. Two vertical lines accelerating on the retina but moving
%laterally. The lines also move further apart over the interval giving the
%looming cue, despite there being no binocular depth information. Left
%eye's image is always used.
%
%looming = looming only; two horizontal lines moving in depth at an
%accelerating rate on the retina. There is no binocular information, but
%the lines move apart over the duration of the interval, so there is
%looming information.

%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window
%this is already in the code somewhere, I should find where and make it
%consistent.

trialData.validTrial = false;
trialData.abortNow   = false;

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    
    thisFilename = ['myMovie_', conditionInfo.label, '_', conditionInfo.movieString, '.mov'];
    
    % Only video, no sound:
    % We raise video quality to 50% for decent looking movies. See
    % comments in if-branch for more details about codec settings.
    movie = Screen('CreateMovie', expInfo.curWindow, thisFilename, 2*screenXpixels, 2*screenYpixels, 60, ':CodecSettings=Videoquality=.9 Profile=2');
end

movieRect = Screen('Rect', expInfo.curWindow);
movieRect = movieRect*2;

expInfo.lw = 1;
fixationInfo(1).type    = 'cross';
fixationInfo(1).fixLineWidthPix = 1;
fixationInfo(2).type = 'noiseFrame';
expInfo = drawFixation(expInfo, fixationInfo);


vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    Screen('AddFrameToMovie', expInfo.curWindow,...
        movieRect);
end

%eye information
IOD = 6; %Interocular distance.
%Eventually need to ask this at the beginning of the experiment
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, expInfo.viewingDistance]; %the fixation point in our coordinate system
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system

nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;
%number of frames displayed during JMA: added round because  it needs to be
%an integer. the duration (in seconds) that is specified

%this section should only be used with the monocular fast speeds and the
%second set of speeds for the standardised value to be correct.
if isfield(conditionInfo, 'fixedDistance') && conditionInfo.fixedDistance 
    
    velPerFrameInterval = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;
    
    standardvelPerFrame = -0.6667; %hardcoded, only works with monocular fast speeds!
    normalisedVelPerFrame = velPerFrameInterval/standardvelPerFrame;
    nFramesInterval = round((nFramesSection1 + nFramesSection2)/normalisedVelPerFrame);
    
elseif isfield(conditionInfo, 'L1velCmPerFrameSection1')
    
    L1velCmPerFrameSection1 = conditionInfo.L1velocityCmPerSecSection1*expInfo.ifi;
    L1velCmPerFrameSection2 = conditionInfo.L1velocityCmPerSecSection2*expInfo.ifi;
    
    L2velCmPerFrameSection1 = conditionInfo.L2velocityCmPerSecSection1*expInfo.ifi;
    L2velCmPerFrameSection2 = conditionInfo.L2velocityCmPerSecSection2*expInfo.ifi;
    
    R1velCmPerFrameSection1 = conditionInfo.R1velocityCmPerSecSection1*expInfo.ifi;
    R1velCmPerFrameSection2 = conditionInfo.R1velocityCmPerSecSection2*expInfo.ifi;
    
    R2velCmPerFrameSection1 = conditionInfo.R2velocityCmPerSecSection1*expInfo.ifi;
    R2velCmPerFrameSection2 = conditionInfo.R2velocityCmPerSecSection2*expInfo.ifi;
    
else
        velCmPerFrameSection1  = conditionInfo.velocityCmPerSecSection1*expInfo.ifi;
    velCmPerFrameSection2  = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;
end

velPerFrameInterval = conditionInfo.velocityCmPerSecSection2*expInfo.ifi;


trialData.flipTimes = NaN(nFramesTotal,1);
frameIdx = 1;

expInfo.startingDepth = expInfo.viewingDistance + conditionInfo.depthStart;

%% Choosing and running the stimulus -- Stereo only (single line)
if strcmp(conditionInfo.stimType, 'cd'); %%strcmp seems to work better than == for this.
    %Checking if the stimulus type is CD only.
    % Changing disparity stimulus -- single vertical line for each eye
    objectStart = [conditionInfo.startPos, 0, expInfo.startingDepth];
    %the single line "object" starting position
    
    objectCurrentPosition = objectStart;
    [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    %trig for the object's current position on the screen
    
    pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
    %of the line on the screen in pixels for the left eye
    LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
    %of the line on the screen in pixels -- relative to the centre of X for
    %the left eye
    
    %same as for the left eye above but for the right eye
    pixelDistanceR = expInfo.pixPerCm * screenR(1);
    LinePosR = round(expInfo.center(1) + pixelDistanceR);
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], expInfo.lw);
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
    end
    
    for iFrame = 1:nFramesSection1, %for each frame until you reach the maximum number of frames
        %first section of the trial at 1 speed
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], expInfo.lw); %drawing the line in the right eye
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrameSection1; %changing the object's current position in space (cm) with the velocity (cm)
        [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR); %calculating the new position of the line on the screen for both eyes
        %For the left eye
        pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
        %of the line on the screen in pixels for the left eye
        LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
        %of the line on the screen in pixels -- relative to the centre of X for
        %the left eye
        %For the right eye
        %same as for the left eye above but for the right eye
        pixelDistanceR = expInfo.pixPerCm * screenR(1);
        LinePosR = round(expInfo.center(1) + pixelDistanceR);
    end
    
    for iFrame = 1:nFramesSection2, %for each frame until you reach the maximum number of frames
        %second section of the trial potentially at a different speed
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], expInfo.lw); %drawing the line in the right eye
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrameSection2; %changing the object's current position in space (cm) with the velocity (cm)
        [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR); %calculating the new position of the line on the screen for both eyes
        %For the left eye
        pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
        %of the line on the screen in pixels for the left eye
        LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
        %of the line on the screen in pixels -- relative to the centre of X for
        %the left eye
        %For the right eye
        %same as for the left eye above but for the right eye
        pixelDistanceR = expInfo.pixPerCm * screenR(1);
        LinePosR = round(expInfo.center(1) + pixelDistanceR);
    end
    %% Single eye view of cd stimulus to both eyes -- contains acceleration
    %not representative of a stimulus moving at a constant speed laterally
    %in the world.
elseif strcmp(conditionInfo.stimType, 'lateralCd');
    
    objectStart = [conditionInfo.startPos, 0, expInfo.startingDepth];
    %the single line "object" starting position
    
    objectCurrentPosition = objectStart;
    [screenL, ~] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    %trig for the object's current position on the screen
    
    pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
    %of the line on the screen in pixels for the left eye
    LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
    %of the line on the screen in pixels -- relative to the centre of X for
    %the left eye
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw);
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
    end
    
    for iFrame = 1:nFramesSection1, %for each frame until you reach the maximum number of frames
        %first section of the trial at 1 speed
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the right eye
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrameSection1; %changing the object's current position in space (cm) with the velocity (cm)
        [screenL, ~] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR); %calculating the new position of the line on the screen for both eyes
        %For the left eye
        pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
        %of the line on the screen in pixels for the left eye
        LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
        %of the line on the screen in pixels -- relative to the centre of X for
        %the left eye

    end
    
    for iFrame = 1:nFramesSection2, %for each frame until you reach the maximum number of frames
        %second section of the trial potentially at a different speed
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], expInfo.lw); %drawing the line in the right eye
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrameSection2; %changing the object's current position in space (cm) with the velocity (cm)
        [screenL, ~] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR); %calculating the new position of the line on the screen for both eyes
        %For the left eye
        pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
        %of the line on the screen in pixels for the left eye
        LinePosL = round(expInfo.center(1) + pixelDistanceL); %the adjusted position
        %of the line on the screen in pixels -- relative to the centre of X for
        %the left eye
       
    end
    
    %% Combination stimulus -- two vertical lines for each eye
elseif strcmp(conditionInfo.stimType, 'combined');
    
    L1LineStart = [conditionInfo.objectOneStartPos, 0, expInfo.startingDepth];
    %the start position of the first line
    L2LineStart = [conditionInfo.objectTwoStartPos, 0, expInfo.startingDepth];
    %the start position of the second line
    objectOneCurrentPosition = L1LineStart;
    [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the first line onto the
    %screen
    
    objectTwoCurrentPosition = L2LineStart;
    [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the second line onto the
    %screen
    
    pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
    LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
    %finding the position of the first line in the left eye in pixels
    
    pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
    LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
    %finding the position of the second line in the left eye in pixels
    pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
    LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
    %finding the position of the first line in the right eye in pixels
    
    pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
    LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
    %finding the position of hte second line in the right eye in pixels
    
    %     LinePosLoneStart = LinePosLone;
    %     LinePosLtwoStart = LinePosLtwo;
    %     LinePosRoneStart = LinePosRone;
    %     LinePosRtwoStart = LinePosRtwo;
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
 
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
       
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
    end
    
    for iFrame = 1:nFramesSection1, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
       
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrameSection1; %finding the new object position for the first line
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrameSection1; %finding the new object position for the second line
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        
        %For the right eye
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
        %first line in the right eye
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
        %second line in the right eye
    end
    
    for iFrame = 1:nFramesSection2, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrameSection2; %finding the new object position for the first line
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrameSection2; %finding the new object position for the second line
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        
        %For the right eye -- same as above but for the right eye
        %rather than the left.
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
        %first line in the right eye
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
        %second line in the right eye
    end
    
    %% constant retinal speed combined stimulus -- two vertical lines moving laterally at constant retinal speed
elseif strcmp(conditionInfo.stimType, 'combined_retinal_lateral');
    L1LineStart = [conditionInfo.objectOneStartPos, 0, expInfo.startingDepth];
    %the start position of the first line
    L2LineStart = [conditionInfo.objectTwoStartPos, 0, expInfo.startingDepth];
    %the start position of the second line
    objectOneCurrentPosition = L1LineStart;
    [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the first line onto the
    %screen
    
    objectTwoCurrentPosition = L2LineStart;
    [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the second line onto the
    %screen
    
    pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
    LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
    %finding the position of the first line in the left eye in pixels
    
    pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
    LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
    %finding the position of the second line in the left eye in pixels
    pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
    LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
    %finding the position of the first line in the right eye in pixels
    
    pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
    LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
    %finding the position of hte second line in the right eye in pixels
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
    end
    
    for iFrame = 1:nFramesSection1, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(1) = objectOneCurrentPosition(1) + velCmPerFrameSection1; %finding the new object position for the first line
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(1) = objectTwoCurrentPosition(1) + velCmPerFrameSection1; %finding the new object position for the second line
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
        %first line in the right eye
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
        %second line in the right eye
    end
    
    for iFrame = 1:nFramesSection2, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(1) = objectOneCurrentPosition(1) + velCmPerFrameSection2; %finding the new object position for the first line
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(1) = objectTwoCurrentPosition(1) + velCmPerFrameSection2; %finding the new object position for the second line
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        
        %For the right eye -- the same commands as above but for the
        %right eye rather than the left.
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(expInfo.center(1) + pixelDistanceRone);
        %first line in the right eye
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(expInfo.center(1) + pixelDistanceRtwo);
        %second line in the right eye
    end
    %% constant retinal speed in depth stimulus -- two vertical lines moving in depth at constant retinal speed
elseif strcmp(conditionInfo.stimType, 'combined_retinal_depth');
    %contains size change and binocular information, but is an
    %unrealistic stimulus
    %starting positions
    L1LineStartCm = conditionInfo.L1StartPos;
    L2LineStartCm = conditionInfo.L2StartPos;
    
    R1LineStartCm = conditionInfo.R1StartPos;
    R2LineStartCm = conditionInfo.R2StartPos;
    
    L1currentPosCm = L1LineStartCm;
    L2currentPosCm = L2LineStartCm;
    R1currentPosCm = R1LineStartCm;
    R2currentPosCm = R2LineStartCm;
    
    L1PixDistance = expInfo.pixPerCm * L1currentPosCm;
    L1PixPos = round(expInfo.center(1) + L1PixDistance);
    %finding the position of the first line in the left eye in pixels
    
    L2PixDistance = expInfo.pixPerCm * L2currentPosCm;
    L2PixPos = round(expInfo.center(1) + L2PixDistance);
    
    R1PixDistance = expInfo.pixPerCm * R1currentPosCm;
    R1PixPos = round(expInfo.center(1) + R1PixDistance);
    
    R2PixDistance = expInfo.pixPerCm * R2currentPosCm;
    R2PixPos = round(expInfo.center(1) + R2PixDistance);
    
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [L1PixPos, L1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [L2PixPos, L2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [R1PixPos, R1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [R2PixPos, R2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
    end
    
    for iFrame = 1:nFramesSection1, %same as above
        
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [L1PixPos, L1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [L2PixPos, L2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [R1PixPos, R1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [R2PixPos, R2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        L1currentPosCm = L1currentPosCm + L1velCmPerFrameSection1; %finding the new object position for the first line
        L2currentPosCm = L2currentPosCm + L2velCmPerFrameSection1;
        R1currentPosCm = R1currentPosCm + R1velCmPerFrameSection1;
        R2currentPosCm = R2currentPosCm + R2velCmPerFrameSection1;
        
        L1PixDistance = expInfo.pixPerCm * L1currentPosCm;
        L1PixPos = round(expInfo.center(1) + L1PixDistance);
        %finding the position of the first line in the left eye in pixels
        
        L2PixDistance = expInfo.pixPerCm * L2currentPosCm;
        L2PixPos = round(expInfo.center(1) + L2PixDistance);
        
        R1PixDistance = expInfo.pixPerCm * R1currentPosCm;
        R1PixPos = round(expInfo.center(1) + R1PixDistance);
        
        R2PixDistance = expInfo.pixPerCm * R2currentPosCm;
        R2PixPos = round(expInfo.center(1) + R2PixDistance);
    end
    
    for iFrame = 1:nFramesSection2, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [L1PixPos, L1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [L2PixPos, L2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [R1PixPos, R1PixPos ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [R2PixPos, R2PixPos ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        L1currentPosCm = L1currentPosCm + L1velCmPerFrameSection2; %finding the new object position for the first line
        L2currentPosCm = L2currentPosCm + L2velCmPerFrameSection2;
        R1currentPosCm = R1currentPosCm + R1velCmPerFrameSection2;
        R2currentPosCm = R2currentPosCm + R2velCmPerFrameSection2;
        
        L1PixDistance = expInfo.pixPerCm * L1currentPosCm;
        L1PixPos = round(expInfo.center(1) + L1PixDistance);
        %finding the position of the first line in the left eye in pixels
        
        L2PixDistance = expInfo.pixPerCm * L2currentPosCm;
        L2PixPos = round(expInfo.center(1) + L2PixDistance);
        
        R1PixDistance = expInfo.pixPerCm * R1currentPosCm;
        R1PixPos = round(expInfo.center(1) + R1PixDistance);
        
        R2PixDistance = expInfo.pixPerCm * R2currentPosCm;
        R2PixPos = round(expInfo.center(1) + R2PixDistance);
    end
    
    %% Lateral combined stimulus -- two vertical lines moving sideways
    %contains acceleration, not representative of an object moving
    %laterally in the real world at constant speed.
elseif strcmp(conditionInfo.stimType, 'lateralCombined');
    
    L1LineStart = [conditionInfo.objectOneStartPos, 0, expInfo.startingDepth];
    %the start position of the first line
    L2LineStart = [conditionInfo.objectTwoStartPos, 0, expInfo.startingDepth];
    %the start position of the second line
    objectOneCurrentPosition = L1LineStart;
    [screenLone, ~] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the first line onto the
    %screen
    
    objectTwoCurrentPosition = L2LineStart;
    [screenLtwo, ~] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
    %transferring this initial position for the second line onto the
    %screen
    
    pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
    LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
    %finding the position of the first line in the left eye in pixels
    
    pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
    LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
    %finding the position of the second line in the left eye in pixels
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
    end
    
    for iFrame = 1:nFramesSection1, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrameSection1; %finding the new object position for the first line
        [screenLone, ~] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrameSection1; %finding the new object position for the second line
        [screenLtwo, ~] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        
    end
    
    for iFrame = 1:nFramesSection2, %same as above
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], expInfo.lw); %drawing the first line (left)
        Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], expInfo.lw); %drawing the second line (right)
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
        objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrameSection2; %finding the new object position for the first line
        [screenLone, ~] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrameSection2; %finding the new object position for the second line
        [screenLtwo, ~] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this new position into positions on the two halves of the screen
        
        %For the left eye
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        %the new unadjusted pixel distance for the first line in the left eye
        LinePosLone = round(expInfo.center(1) + pixelDistanceLone);
        %the new adjusted position of the line (in X) on the screen
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        %the new unadjusted pixel distance for the second line in the
        %left eye
        LinePosLtwo = round(expInfo.center(1) + pixelDistanceLtwo);
        %the new adjusted position in X for the second line in the left
        %eye
        
    end
    
    %% Looming only stimulus -- two horizontal lines
elseif strcmp(conditionInfo.stimType, 'looming');
    
    %One and two in the names refer to the first and second horizontal line
    %-- screenOne = the screen position of the first line, etc. At
    %the moment the top line is line one.
    
    HorizontalObjectOneStart = [0, conditionInfo.horizontalOneStartPos, expInfo.startingDepth];
    %the start position for the first horizontal line
    HorizontalObjectTwoStart = [0, conditionInfo.horizontalTwoStartPos, expInfo.startingDepth];
    %the start position for the second horizontal line
    
    objectOneCurrentHorizontalPosition = HorizontalObjectOneStart;
    [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
    %uses new calculateHorizontalScreenLocation function which
    %is very similar to calculateScreenLocation but in terms of
    %y and z rather than x and z. -- finds screenY
    
    %line 1
    HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
    HorizontalOneLinePos = round(expInfo.center(2) + HorizontalOnePixelDistance);
    trialData.obj1StartPos = HorizontalOneLinePos;
    %finds the line position in a similar way to how it is found
    %previously
    
    %line 2
    objectTwoCurrentHorizontalPosition = HorizontalObjectTwoStart;
    [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
    %again uses calculateHorizontalScreenLocation to find screenY
    %and work out the position on the screen in pixels (below)
    HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
    HorizontalTwoLinePos = round(expInfo.center(2) + HorizontalTwoPixelDistance);
    trialData.obj2StartPos = HorizontalTwoLinePos;
    
    for iFrame = 1:nFramesPreStim %during the pre-stimulus duration have the lines appear in a fixed position
        % For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw); %draw line 1 = top line
        Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw); %draw line 2 = bottom line
        
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw);
        Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw);
        
        expInfo = drawFixation(expInfo, fixationInfo);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        
        if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            Screen('AddFrameToMovie', expInfo.curWindow,...
                movieRect);
        end
        
        trialData.flipTimes(frameIdx) = vbl;
        frameIdx = frameIdx+1;
        
    end
    if isfield(conditionInfo, 'fixedDistance') && conditionInfo.fixedDistance
        for iFrame = 1:nFramesInterval
        % For the left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw); %draw line 1 = top line
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw); %draw line 2 = bottom line
            
            %For the right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw);
            
            expInfo = drawFixation(expInfo, fixationInfo);
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            
            if isfield(expInfo,'writeMovie') && expInfo.writeMovie
                Screen('AddFrameToMovie', expInfo.curWindow,...
                    movieRect);
            end
            
            trialData.flipTimes(frameIdx) = vbl;
            frameIdx = frameIdx+1;
            
            %Calculating the new screen position for horizontal line 1
            %in a similar way to how the new positions are calculated
            %above.
            %uses new calculateHorizontalScreenLocation function which
            %is very similar to calculateScreenLocation but in terms of
            %y and z rather than x and z.
            objectOneCurrentHorizontalPosition(3) = objectOneCurrentHorizontalPosition(3) + velPerFrameInterval;
            [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
            
            HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
            HorizontalOneLinePos = round(expInfo.center(2) + HorizontalOnePixelDistance);
            
            %Calculating the new screen position for horizontal line 2
            %in a similar way to how the new positions are calculated
            %above.
            objectTwoCurrentHorizontalPosition(3) = objectTwoCurrentHorizontalPosition(3) + velPerFrameInterval;
            [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
            
            HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
            HorizontalTwoLinePos = round(expInfo.center(2) + HorizontalTwoPixelDistance);
            %Doing calculations for the second line position similarly
            %to above.
        end
        
    else
        
        for iFrame = 1:nFramesSection1, %same as for the other stimuli
            % For the left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw); %draw line 1 = top line
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw); %draw line 2 = bottom line
            
            %For the right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw);
            
            expInfo = drawFixation(expInfo, fixationInfo);
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            
            if isfield(expInfo,'writeMovie') && expInfo.writeMovie
                Screen('AddFrameToMovie', expInfo.curWindow,...
                    movieRect);
            end
            
            trialData.flipTimes(frameIdx) = vbl;
            frameIdx = frameIdx+1;
            
            %Calculating the new screen position for horizontal line 1
            %in a similar way to how the new positions are calculated
            %above.
            %uses new calculateHorizontalScreenLocation function which
            %is very similar to calculateScreenLocation but in terms of
            %y and z rather than x and z.
            objectOneCurrentHorizontalPosition(3) = objectOneCurrentHorizontalPosition(3) + velCmPerFrameSection1;
            [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
            
            HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
            HorizontalOneLinePos = round(expInfo.center(2) + HorizontalOnePixelDistance);
            
            %Calculating the new screen position for horizontal line 2
            %in a similar way to how the new positions are calculated
            %above.
            objectTwoCurrentHorizontalPosition(3) = objectTwoCurrentHorizontalPosition(3) + velCmPerFrameSection1;
            [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
            
            HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
            HorizontalTwoLinePos = round(expInfo.center(2) + HorizontalTwoPixelDistance);
            %Doing calculations for the second line position similarly
            %to above.
        end
        
        for iFrame = 1:nFramesSection2, %same as for the other stimuli
            % For the left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw); %draw line 1 = top line
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw); %draw line 2 = bottom line
          
            %For the right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], expInfo.lw);
            Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], expInfo.lw);

            expInfo = drawFixation(expInfo, fixationInfo);
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            
            if isfield(expInfo,'writeMovie') && expInfo.writeMovie
                Screen('AddFrameToMovie', expInfo.curWindow,...
                    movieRect);
            end
            
            trialData.flipTimes(frameIdx) = vbl;
            frameIdx = frameIdx+1;
            
            %Calculating the new screen position for horizontal line 1
            %in a similar way to how the new positions are calculated
            %above.
            %uses new calculateHorizontalScreenLocation function which
            %is very similar to calculateScreenLocation but in terms of
            %y and z rather than x and z.
            objectOneCurrentHorizontalPosition(3) = objectOneCurrentHorizontalPosition(3) + velCmPerFrameSection2;
            [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
            
            HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
            HorizontalOneLinePos = round(expInfo.center(2) + HorizontalOnePixelDistance);
            
            %Calculating the new screen position for horizontal line 2
            %in a similar way to how the new positions are calculated
            %above.
            objectTwoCurrentHorizontalPosition(3) = objectTwoCurrentHorizontalPosition(3) + velCmPerFrameSection2;
            [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
            
            HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
            HorizontalTwoLinePos = round(expInfo.center(2) + HorizontalTwoPixelDistance);
            
            %Doing calculations for the second line position similarly
            %to above.
        end
    end
    trialData.obj1EndPos = HorizontalOneLinePos;
    trialData.obj2EndPos = HorizontalTwoLinePos;
end

expInfo = drawFixation(expInfo, fixationInfo);

Screen('Flip', expInfo.curWindow); %the final necessary flip.

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    Screen('AddFrameToMovie', expInfo.curWindow,...
        movieRect);
end

trialData.flipTimes(frameIdx) = vbl;
frameIdx = frameIdx+1;

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    Screen('FinalizeMovie', movie);
end

