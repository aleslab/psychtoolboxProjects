function [trialData] = MoveLineTrial(expInfo, conditionInfo)
%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window

trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen

%% Calculating positions for the line

IOD = 6; %Interocular distance. Eventually need to ask this at the
%beginning of the experiment
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, expInfo.viewingDistance]; %the fixation point in our coordinate system
objectStart = [conditionInfo.startPos, 0, expInfo.viewingDistance];
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system

screenXCentre = screenXpixels/2;

%% Drawing the fixation cross and moving line

lw = 1; %linewidth in pixels

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

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;

fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
FixCoords = [fixXCoords; fixYCoords];

% Set the line width for our fixation cross
fixWidthPix = 1;

%AL -- there's something weird going on here where I think the "left" and
%"right" are actually the wrong way around as when it is run for an
%approaching stimulus that increases in speed(e.g. -57) it appears to be
%moving away. If you swap the stereo "screens" then this appears to fix the
%problem but then I'm not sure if everything is then in the correct place.

for iFrame = 1:nFrames,
  %left eye
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); 
    Screen('DrawLines', expInfo.curWindow, FixCoords, 0,  fixWidthPix, expInfo.center, 2)
    Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw);
  %right eye  
    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); 
    Screen('DrawLines', expInfo.curWindow, FixCoords, 0,  fixWidthPix, expInfo.center, 2)  
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

Screen('Flip', expInfo.curWindow);

end
