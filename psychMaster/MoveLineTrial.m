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

%% Changing disparity stimulus -- single vertical line for each eye

if conditionInfo.stimType == 'cd'
    
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
    
    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 20;
    
    fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    FixCoords = [fixXCoords; fixYCoords];
    
    % Set the line width for our fixation cross
    fixWidthPix = 1;
    
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
end

%% Combination stimulus -- two vertical lines for each eye

% if conditionInfo.stimType == 'combined';
% 
% end

%% Looming only stimulus -- two horizontal lines

% if conditionInfo.stimType == 'looming';
%     
% end

Screen('Flip', expInfo.curWindow);

end
