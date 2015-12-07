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

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;

fixxCoords = [-fixCrossDimPix fixCrossDimPix 0 0 LinePosL LinePosL ];
fixyCoords = [0 0 -fixCrossDimPix fixCrossDimPix 0 screenYpixels];
allCoords = [fixxCoords; fixyCoords];
% Set the line width for our fixation cross
fixWidthPix = 2;

%Screen('DrawLines', expInfo.curWindow, allCoords, 0,  fixWidthPix, expInfo.center, 2);

%Screen('Flip', expInfo.curWindow);

for iFrame = 1:nFrames,
    
   %moveLineCoords = [LinePosL LinePosL  0 screenYpixels];
   %allCoords = [xCoords; yCoords; moveLineCoords]; 
    %that the line moves towards the right


    %Screen('DrawLines', expInfo.curWindow, allCoords, lw);
    
    Screen('DrawLines', expInfo.curWindow, allCoords, 0,  fixWidthPix, expInfo.center, 2)
    
    Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw);
    vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
    
    objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrame;
    [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    
    pixelDistanceL = expInfo.pixPerCm * screenL(1);
    LinePosL = round(screenXCentre + pixelDistanceL);
    
end

Screen('Flip', expInfo.curWindow);

end
