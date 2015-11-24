function [trialData] = MoveLineTrial(screenInfo, conditionInfo)
		
%% making the line move
[screenXpixels, screenYpixels] = Screen('WindowSize', screenInfo.curWindow); 
%get the number of pixels in the window

%ifi = Screen('GetFlipInterval', screenInfo.curWindow); %inter-frame interval 
%for the current window on the screen.

%totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration+conditionInfo.postStimDuration;
%nFrames = round(totalDuration / screenInfo.ifi);
%trialData.actualDuration = nFrames*screenInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', screenInfo.curWindow); %flipping to the screen
lw = 1; %linewidth in pixels



%xinitial = 10; %initial x position for line
%cmdistance = 2; %distance of line to move in cm
pixeldistance = screenInfo.pixPerCm *conditionInfo.cmDistance; %the distance in pixels 
%that we want to move -- this gives a value of 12.5 pixels to 1 cm which
%according to other unit converters is wrong... is there a problem with
%this line or is there a problem with how the screenInfo.pixPerCm is
%specified in openExperiment?
% JMA:  Yes it's wrong. In order for it to be correct the display has to be
% calibarated.  That's not implemented yet. So don't worry about the exact
% numbers. 
xfinal = conditionInfo.startPos + pixeldistance; %where the line ends in x (pixels)
%durationsecs = conditionInfo.stimDuration; %the time in seconds that we want the line to move for
nFrames = round(conditionInfo.stimDuration / screenInfo.ifi); %number of frames displayed during JMA: added round because  it needs to be an integer.
%the duration (in seconds) that is specified

%xv = pixeldistance / screenInfo.ifi; % this does not work yet

%To get velocity in pixelsPerIfi we need to do a dimensional analysis.
% The way it was before was set to be a velocity of 2 cm per ifi or 120 cm/s
% We start with a value in CM/Sec (could be something else 
% CM/Sec  * ( Pix/CM) = Pix/Sec (CM cancels)
% (Pix/Sec) * (Sec/Frame) = PixPerFrame (Sec cancels)

velPixPerFrame = conditionInfo.velocityCmPerSec*screenInfo.pixPerCm*screenInfo.ifi;
xv = velPixPerFrame;

if conditionInfo.startPos > xfinal;
        
        while conditionInfo.startPos > xfinal;
            conditionInfo.startPos =mod(conditionInfo.startPos-xv, screenXpixels); %the part that actually gets
            %the line to move within the while loop. taking xv off the value to
            %move to the left.
            Screen('DrawLines', screenInfo.curWindow, [conditionInfo.startPos, conditionInfo.startPos ; 0, screenYpixels], lw);
            vbl=Screen('Flip', screenInfo.curWindow,vbl+screenInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            %if this isn't flipped within the while loop you won't see the line
            %being moved across the window.
            
        end
      
else
        while conditionInfo.startPos < xfinal;
            conditionInfo.startPos =mod(conditionInfo.startPos+xv, screenXpixels); %adding xv onto the value so
            %that the line moves towards the right
            Screen('DrawLines', screenInfo.curWindow, [conditionInfo.startPos, conditionInfo.startPos ; 0, screenYpixels], lw);
            vbl=Screen('Flip', screenInfo.curWindow,vbl+screenInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            %Drawing and flipping everything onto the screen so that it appears
            %as it should.
        end
end

% contscreen = ('Press the spacebar to continue ');
%     DrawFormattedText(screenInfo.curWindow, contscreen,'left', 'center', 1,[],[],[],[],[],screenInfo.screenRect);
Screen('Flip', screenInfo.curWindow);
% 
% KbStrokeWait;
% trialData.firstPress = 1;
% feedbackMsg  = 'Press any button to continue';
% trialData.feedbackMsg = feedbackMsg;
% trialData.validTrial = true;
%% for testing to check values
% disp(pixeldistance);
% disp(screenInfo.ifi);
%disp(nFrames);
%disp(xv);
%disp(conditionInfo.velocityCmPerSec);