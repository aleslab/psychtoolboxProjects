%Adapted from Peter Scarfe's PTB demos (at http://peterscarfe.com/) and 
%the PTB-3 demos.
% Clear the workspace and the screen
close all;
clear all; %#ok<CLSCR>
sca

stereoMode = 4;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

screenNumber = max(screens);

% Define black and white (white will be 1 and black 0).
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%% Get the distance and speed for the line to move
xRange = false; 
while (~ xRange) %while not in the range of x pixels

    xdistancequestion = 'How far would you like the line to move? ';
    
   xdistance = input(xdistancequestion); %distance for the line to move is the input
    
    if xdistance <= 480 && xdistance >= 0 %if the distance is outside the 
    %specified range for the lilac room
    
%      if xdistance <= 320 && xdistance >= 0 %if the distance is outside the 
%     %specified range for the CRT in the lab
        
    xRange = true;
    
    else
        
        xRange = false;
        disp('Please enter a value in the range 0-960'); %lilac room
        
%         xRange = false;
%         disp('Please enter a value in the range 0-640'); %lab crt
         
    end
end 

speedquestion = 'How fast would you like the line to move across the screen? ';
    
xv = input(speedquestion); %xv = the speed that the line is moving 
   %through the x axis. Not entirely sure how this translates into metres
   %per second/ millimetres per second/ degrees per second?
   %As coded here it's in pixels/(time to iterate while loop). Most likely a single video frame so:
   % Pixels / ifi

%% Generating the window with the line

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2, stereoMode); 
%stereomode part = adapted from Peter scarfe's square in depth demo. Not
%entirely sure what the [], 32, 2 want to be.
Screen('Flip', window);

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window); %taken from PTB-3 MovingLineDemo
vbl=Screen('Flip', window); %taken from PTB-3 MovingLineDemo

% basically for adapting this code into the wrapper you just need to start
% here. The wrapper script handles everything above.
%-------------------------------------------------------
% function [trialData] = drawDotTrial(screenInfo, conditionInfo)
%
lw = 5; %linewidth

% When drawing in stereo we have to select which eyes buffer we are going
% to draw in. These are labelled 0 for left and 1 for right.

xposL = 480; %320 in lab %480 in lilac
xposR = 480; %320 in lab %480 in lilac

%480 half way through half of the screen so that when viewed as fused
%through the stereoscope you don't get crossover of the lines.

currentxL = xposL-xdistance;
currentxR = xposR+xdistance;

% Select left-eye image buffer for drawing (buffer = 0)

%We'll change this to calculate a stim duration later.
continueDrawing = true;
% Now draw our left eyes line
while continueDrawing


    xposL=mod(xposL-xv, screenXpixels); %the part that actually gets 
    %the line to move within the while loop. taking xv off the value to
     %move to the left.
    xposR=mod(xposR+xv, screenXpixels); %adding xv onto the value so
     %that the line moves towards the right

    %Draw Left Image:
    Screen('SelectStereoDrawBuffer', window, 0);     
    Screen('DrawLines', window, [xposL, xposL ; 0, screenYpixels], lw);
        
        

    % % Select right-eye image buffer for drawing (buffer = 1)
    Screen('SelectStereoDrawBuffer', window, 1);

    % Now draw our right eyes line
    Screen('DrawLines', window, [xposR, xposR; 0, screenYpixels], lw);

    %Now show them both.
    vbl=Screen('Flip', window,vbl+ifi/2); %taken from PTB-3 MovingLineDemo
     %Drawing and flipping everything onto the screen so that it appears
     %as it should.
     
     %If either bar hits the limit stop drawing
     if (xposL < currentxL) || (xposR > currentxR)
         continueDrawing = false;
     end
     
end

% How can you make it so that both of the lines are drawn and move
% simultaneously?
%Done.  To do this you need to draw each bar before caling flip.


% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

%This would be the end of your trial script. 
%%%%%
%--------------------------
% This also gets handled by the wrapper script. 
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;