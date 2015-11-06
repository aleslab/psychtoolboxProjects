function [trialData] = MoveLineTrial(screenInfo, conditionInfo)
		
%% making the line move
[screenXpixels, screenYpixels] = Screen('WindowSize', screenInfo.curWindow); 
%get the number of pixels in the window

ifi = Screen('GetFlipInterval', screenInfo.curWindow); %inter-frame interval 
%for the current window on the screen.

%totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration+conditionInfo.postStimDuration;
%nFrames = round(totalDuration / screenInfo.ifi);
%trialData.actualDuration = nFrames*screenInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', screenInfo.curWindow); %flipping to the screen
linerep = 1;
totallinereps = 3;
lw = 1; %linewidth in pixels

xinitial = 0; %initial x position for line
xfinal = 200; %where the line ends in x

cmdistance = 2; %distance of line to move in cm
pixeldistance = screenInfo.pixPerCm *cmdistance;
durationsecs = 1;
nFrames = durationsecs / screenInfo.ifi;
xv = pixeldistance / screenInfo.ifi;
%xv = 5; %speed ( pixels / ifi)

%need to change this so that there isn't the repeat in the line
%change it so that it runs for the duration I specify, not between two
%points -- for now keep duration fixed
%get it so that you take the duration and the distance to generate the
%speed?
while linerep ~= totallinereps;
    
    if xinitial > xfinal;
        
        while xinitial > xfinal;
            xinitial=mod(xinitial-xv, screenXpixels); %the part that actually gets
            %the line to move within the while loop. taking xv off the value to
            %move to the left.
            Screen('DrawLines', screenInfo.curWindow, [xinitial, xinitial ; 0, screenYpixels], lw);
            vbl=Screen('Flip', screenInfo.curWindow,vbl+ifi/2); %taken from PTB-3 MovingLineDemo
            %if this isn't flipped within the while loop you won't see the line
            %being moved across the window.
            
        end
        linerep = linerep+1;
        xinitial = 10;
    else
        while xinitial < xfinal;
            xinitial=mod(xinitial+xv, screenXpixels); %adding xv onto the value so
            %that the line moves towards the right
            Screen('DrawLines', screenInfo.curWindow, [xinitial, xinitial ; 0, screenYpixels], lw);
            vbl=Screen('Flip', screenInfo.curWindow,vbl+ifi/2); %taken from PTB-3 MovingLineDemo
            %Drawing and flipping everything onto the screen so that it appears
            %as it should.
        end
        linerep = linerep+1;
        xinitial = 10;
    end
end
speedquestion = 'Press the spacebar to continue ';
    DrawFormattedText(screenInfo.curWindow, speedquestion,'left', 'center', 1,[],[],[],[],[],screenInfo.screenRect);
    Screen('Flip', screenInfo.curWindow);

KbStrokeWait;
trialData.firstPress = 1;
feedbackMsg  = ['It works'];
trialData.feedbackMsg = feedbackMsg;
trialData.validTrial = true;
%   feedbackMsg  = ['Invalid Response'];
%     trialData.validTrial = false;
  