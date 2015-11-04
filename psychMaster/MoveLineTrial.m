function [conditionInfo, screenInfo] = MoveLineTrial(screenInfo)
%paradigmName is what will be prepended to data files
screenInfo.paradigmName = 'MoveLineTrial';

%Let's use kbQueue's because they have high performance.
screenInfo.useKbQueue = true;

screenInfo.instructions = 'Press any key to start';
 
KbStrokeWait;

%% making the line move
[screenXpixels, screenYpixels] = Screen('WindowSize', screenInfo.curWindow); 
%get the number of pixels in the window

ifi = Screen('GetFlipInterval', screenInfo.curWindow); %inter-frame interval 
%for the current window on the screen.

vbl=Screen('Flip', screenInfo.curWindow); %flipping to the screen

lw = 1; %linewidth
xinitial = 10; %initial x position for line
xfinal = 200; %where the line ends in x
xv = 5; %speed (most likely Pixels / ifi)

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
else
    while xinitial < xfinal; 
     xinitial=mod(xinitial+xv, screenXpixels); %adding xv onto the value so
     %that the line moves towards the right
        Screen('DrawLines', screenInfo.curWindow, [xinitial, xinitial ; 0, screenYpixels], lw); 
        vbl=Screen('Flip', screenInfo.curWindow,vbl+ifi/2); %taken from PTB-3 MovingLineDemo
        %Drawing and flipping everything onto the screen so that it appears
        %as it should.

    end 
end    

%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
%Condition 1 is the target absent condition.
conditionInfo(1).stimDuration     = 2; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 3;    %Post trial window for waiting for a response
% conditionInfo(1).sigma=.2;
% conditionInfo(1).freq = 4;
conditionInfo(1).targetAmp = 0; %adapt to x distance
conditionInfo(1).nReps = 2; %number of repeats
% conditionInfo(1).stimRadiusCm   = 1;    %stimulus size in cm;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

% conditionInfo(2) = conditionInfo(1);
% conditionInfo(2).targetAmp = 10;
% conditionInfo(2).nReps = 1;
% 
% conditionInfo(3) = conditionInfo(1);
% conditionInfo(3).targetAmp = 30;
% conditionInfo(3).nReps = 1;
% 
% conditionInfo(4) = conditionInfo(1);
% conditionInfo(4).targetAmp = 80;
% conditionInfo(4).nReps = 1;

KbStrokeWait;

sca;