function [trialData] = MoveLineTrial(expInfo, conditionInfo)
%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window
%this is already in the code somewhere, I should find where and make it
%consistent.

trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen

%eye information
IOD = 6; %Interocular distance.
%Eventually need to ask this at the beginning of the experiment
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, expInfo.viewingDistance]; %the fixation point in our coordinate system
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system

lw = 1; %linewidth in pixels

screenXCentre = screenXpixels/2; %again this is already in the code and I
%should change it to be consistent.

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;

fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
FixCoords = [fixXCoords; fixYCoords];

% Set the line width for our fixation cross
fixWidthPix = 1;

%% Choosing and running the stimulus
if strcmp(conditionInfo.stimType, 'cd');
    %% Changing disparity stimulus -- single vertical line for each eye
    objectStart = [conditionInfo.startPos, 0, expInfo.viewingDistance];
    
    nFrames = round(conditionInfo.stimDuration / expInfo.ifi); %number of
    %frames displayed during JMA: added round because  it needs to be an
    %integer. the duration (in seconds) that is specified
    
    velCmPerFrame  = conditionInfo.velocityCmPerSec*expInfo.ifi;
    
    objectCurrentPosition = objectStart;
    [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    
    pixelDistanceL = expInfo.pixPerCm * screenL(1);
    LinePosL = round(screenXCentre + pixelDistanceL);
    
    pixelDistanceR = expInfo.pixPerCm * screenR(1);
    LinePosR = round(screenXCentre + pixelDistanceR);
    
    for iFrame = 1:nFrames,
        %left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw);
        %right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], lw);
        
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrame;
        [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
        %left
        pixelDistanceL = expInfo.pixPerCm * screenL(1);
        LinePosL = round(screenXCentre + pixelDistanceL);
        %right
        pixelDistanceR = expInfo.pixPerCm * screenR(1);
        LinePosR = round(screenXCentre + pixelDistanceR);
    end
    
    
else if strcmp(conditionInfo.stimType, 'combined');
        % Combination stimulus -- two vertical lines for each eye
        objectOneStart = [conditionInfo.objectOneStartPos, 0, expInfo.viewingDistance];
        objectTwoStart = [conditionInfo.objectTwoStartPos, 0, expInfo.viewingDistance];
        nFrames = round(conditionInfo.stimDuration / expInfo.ifi); %number of
        %frames displayed during JMA: added round because  it needs to be an
        %integer. the duration (in seconds) that is specified
        
        velCmPerFrame  = conditionInfo.velocityCmPerSec*expInfo.ifi;
        
        objectOneCurrentPosition = objectOneStart;
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        
        objectTwoCurrentPosition = objectTwoStart;
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        LinePosLone = round(screenXCentre + pixelDistanceLone);
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        LinePosLtwo = round(screenXCentre + pixelDistanceLtwo);
        
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(screenXCentre + pixelDistanceRone);
        
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(screenXCentre + pixelDistanceRtwo);
        
        for iFrame = 1:nFrames,
            %left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)
            Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], lw);
            Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], lw);
            %right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)
            Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], lw);
            Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], lw);
            
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            
            objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrame;
            [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
            
            objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrame;
            [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
            
            %left
            pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
            LinePosLone = round(screenXCentre + pixelDistanceLone);
            
            pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
            LinePosLtwo = round(screenXCentre + pixelDistanceLtwo);
            
            %right
            pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
            LinePosRone = round(screenXCentre + pixelDistanceRone);
            
            pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
            LinePosRtwo = round(screenXCentre + pixelDistanceRtwo);
        end
        
        %% Looming only stimulus -- two horizontal lines
        
        %else if strcmp(conditionInfo.stimType, 'combined');
        
        
    end
    
    Screen('Flip', expInfo.curWindow);
    
end
