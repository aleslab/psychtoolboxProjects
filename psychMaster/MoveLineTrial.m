function [trialData] = MoveLineTrial(screenInfo, conditionInfo)
		
%% making the line move
[screenXpixels, screenYpixels] = Screen('WindowSize', screenInfo.curWindow); 
%get the number of pixels in the window

ifi = Screen('GetFlipInterval', screenInfo.curWindow); %inter-frame interval 
%for the current window on the screen.

totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration+conditionInfo.postStimDuration;
nFrames = round(totalDuration / screenInfo.ifi);
trialData.actualDuration = nFrames*screenInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', screenInfo.curWindow); %flipping to the screen
linerep = 1;
totallinereps = 3;
lw = 1; %linewidth
xinitial = 10; %initial x position for line
xfinal = 200; %where the line ends in x
xv = 5; %speed (most likely Pixels / ifi)

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
speedquestion = 'Which of the lines moved faster, the first line (1) or the second line (2)? ';
    DrawFormattedText(screenInfo.curWindow, speedquestion,'left', 'center', 1,[],[],[],[],[],screenInfo.screenRect);
    Screen('Flip', screenInfo.curWindow);
    
keysOfInterest=zeros(1,256);
	keysOfInterest(KbName({'1', '2'}))=1;
	KbQueueCreate(-1, keysOfInterest);
	% Perform some other initializations
	KbQueueStart;
	% Perform some other tasks while key events are being recorded
    
	[ pressed, firstPress]=KbQueueCheck; % Collect keyboard events since KbQueueStart was invoked
   
    if pressed
        
        if firstPress(KbName('1'))
            % Handle press of '1' key
        end
        if firstPress(KbName('2'))
            % Handle press of '2' key
        end
    end
	% Do additional computations
	KbQueueRelease;

%KbStrokeWait;

sca;