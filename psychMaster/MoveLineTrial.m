function [trialData] = MoveLineTrial(expInfo, conditionInfo)
		
%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow); 
%get the number of pixels in the window

trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen



%% Calculating positions for the line
% I think it makes the most sense to do all these calculations in cm and
% then convert to pixels before we draw.

%our coordinate system is that [0,0,0] is the cyclopean point.

viewingDistance = 57; %distance from the cyclopean point to the screen
IOD = 6; %Interocular distance
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, viewingDistance]; %the fixation point in our coordinate system
objectStart = [conditionInfo.startPos, 0, viewingDistance];
objectStartPixels = objectStart * expInfo.pixPerCm;
%objectStart = object; %where we want the line to start from; might need to
%use this in a while loop.
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system
DepthMovement = [0, 0, conditionInfo.cmDistance]; %the movement in depth that we want the person to see
object = objectStart - DepthMovement;
[screenL, screenR] = calculateScreenLocation(fixation, object, eyeL, eyeR);
%call the calculate screen location function to calculate where to draw the
%object on the screen in cm.

%the screens will come out with [desiredX, 0, viewingDistance]

pixelDistanceL = expInfo.pixPerCm * screenL(1); %the distance 
%in pixels that we want to move between the start and the final screen
%position in pixels for the left eye

pixelDistanceR = expInfo.pixPerCm * screenR(1); %the distance 
%in pixels that we want to move between the start and the final screen 
%position in pixels for the right eye

%viewingDistancePixels = expInfo.pixPerCm * viewingDistance;

screenXCentre = screenXpixels/2;

LinePosR = screenXCentre + objectStartPixels(1);
LinePosL = screenXCentre - objectStartPixels(1);

FinalPosR = LinePosR + pixelDistanceR;
FinalPosL = LinePosL - pixelDistanceL;

%% Drawing and moving the line

lw = 1; %linewidth in pixels

nFrames = round(conditionInfo.stimDuration / expInfo.ifi); %number of frames displayed during JMA: added round because  it needs to be an integer.
%the duration (in seconds) that is specified

%To get velocity in pixelsPerIfi we need to do a dimensional analysis.
% The way it was before was set to be a velocity of 2 cm per ifi or 120 cm/s
% We start with a value in CM/Sec (could be something else 
% CM/Sec  * ( Pix/CM) = Pix/Sec (CM cancels)
% (Pix/Sec) * (Sec/Frame) = PixPerFrame (Sec cancels)

velPixPerFrame = conditionInfo.velocityCmPerSec*expInfo.pixPerCm*expInfo.ifi;
velCmPerFrame  = conditionInfo.velocityCmPerSec*expInfo.ifi;
xv = velPixPerFrame;

%continueDrawing = true;
%while continueDrawing

% if LinePosR < FinalPosR;
%     
%     while LinePosR < FinalPosR;
%         LinePosR =mod(LinePosR+xv, screenXpixels); %adding xv onto the value so
%         %that the line moves towards the right
%         Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], lw);
%         vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
%         %Drawing and flipping everything onto the screen so that it appears
%         %as it should.
%     end
%     
% else
%     
%    while LinePosR > FinalPosR;
%         LinePosR =mod(LinePosR-xv, screenXpixels); %adding xv onto the value so
%         %that the line moves towards the right
%         Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], lw);
%         vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
%         %Drawing and flipping everything onto the screen so that it appears
%         %as it should.
%     end
%         
% end
objectCurrentPosition = objectStart;
[screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
        
pixelDistanceL = expInfo.pixPerCm * screenL(1);
LinePosL = round(screenXCentre + pixelDistanceL);

for iFrame = 1:nFrames,
        
        %that the line moves towards the right
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw);
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        %Drawing and flipping everything onto the screen so that it appears
        %as it should.
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrame;
        [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
        
        pixelDistanceL = expInfo.pixPerCm * screenL(1);
        LinePosL = round(screenXCentre + pixelDistanceL);
        
        
        
        
end


%end

Screen('Flip', expInfo.curWindow);

end

