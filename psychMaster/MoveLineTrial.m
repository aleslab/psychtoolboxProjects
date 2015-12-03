function [trialData] = MoveLineTrial(expInfo, conditionInfo)
		
%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow); 
%get the number of pixels in the window

trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen

pixeldistance = expInfo.pixPerCm *conditionInfo.cmDistance; %the distance 
%in pixels that we want to move converted from cm

%% Calculating positions for the line
% I think it makes the most sense to do all these calculations in cm and
% then convert to pixels before we draw.

%our coordinate system is that [0,0,0] is the cyclopean point.

viewingDistance = 57; %distance from the cyclopean point to the screen
IOD = 6; %Interocular distance
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, viewingDistance]; %the fixation point in our coordinate system
object = [conditionInfo.startPos, 0, viewingDistance];
%objectStart = object; %where we want the line to start from; might need to
%use this in a while loop.
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system
DepthMovement = [0, 0, 20]; %the movement in depth that we want the person to see
    
[screenL, screenR] = calculateScreenLocation(fixation, object, eyeL, eyeR);
%call the calculate screen location function to calculate where to draw the
%object on the screen in cm.

%the screens will come out with [desiredX, 0, viewingDistance]


%then need to convert this to pixels using pixel distance.




%screenCentre = [(screenXpixels/2), (screenYpixels/2), viewingDistancepixels];
%centre of the screen in x y z pixels to make our coordinate system work





%% Drawing and moving the line

%I haven't made any changes to this section yet.

lw = 1; %linewidth in pixels

xfinal = conditionInfo.startPos + pixeldistance; %where the line ends in x (pixels)
%durationsecs = conditionInfo.stimDuration; %the time in seconds that we want the line to move for
nFrames = round(conditionInfo.stimDuration / expInfo.ifi); %number of frames displayed during JMA: added round because  it needs to be an integer.
%the duration (in seconds) that is specified

%xv = pixeldistance / screenInfo.ifi; % this does not work yet

%To get velocity in pixelsPerIfi we need to do a dimensional analysis.
% The way it was before was set to be a velocity of 2 cm per ifi or 120 cm/s
% We start with a value in CM/Sec (could be something else 
% CM/Sec  * ( Pix/CM) = Pix/Sec (CM cancels)
% (Pix/Sec) * (Sec/Frame) = PixPerFrame (Sec cancels)

velPixPerFrame = conditionInfo.velocityCmPerSec*expInfo.pixPerCm*expInfo.ifi;
xv = velPixPerFrame;

if conditionInfo.startPos > xfinal;
        
        while conditionInfo.startPos > xfinal;
            conditionInfo.startPos =mod(conditionInfo.startPos-xv, screenXpixels); %the part that actually gets
            %the line to move within the while loop. taking xv off the value to
            %move to the left.
            Screen('DrawLines', expInfo.curWindow, [conditionInfo.startPos, conditionInfo.startPos ; 0, screenYpixels], lw);
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            %if this isn't flipped within the while loop you won't see the line
            %being moved across the window.
            
        end
      
else
        while conditionInfo.startPos < xfinal;
            conditionInfo.startPos =mod(conditionInfo.startPos+xv, screenXpixels); %adding xv onto the value so
            %that the line moves towards the right
            Screen('DrawLines', expInfo.curWindow, [conditionInfo.startPos, conditionInfo.startPos ; 0, screenYpixels], lw);
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            %Drawing and flipping everything onto the screen so that it appears
            %as it should.
        end
end

Screen('Flip', expInfo.curWindow);
