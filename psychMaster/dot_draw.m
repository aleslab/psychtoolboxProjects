%Adapted from Peter Scarfe's Single Dot Demo that generates a
%randomly-positioned red dot on a black background which is available at: 
%http://peterscarfe.com/singleDotDemo.html
% Clear the workspace and the screen
close all;
clear all;
sca

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
%% A piece of code that asks you where you want to position the dot
%X coordinate needs to be within 0-1920 for lilac room screen and the 
%primary screen in the lab; will be different for the lab CRT screen. 
%Ideally need to  check the screen size to check the range but worry about
%that later.
%xrange = [0:1920]; %in the lilac room. this is the actual range.
%yrange = [0:1200]; %in the lilac room 

xRange = false; %not the same as xrange. this is a boolean, but the values 
%should still be within 0 and 1920 for this to be true.
while (~ xRange) %while not xRange

    xquestion = ['Your X coordinate? ']; %asks for your x coordinate
    
    answerx = input(xquestion); %x coordinate is the input
    
    if answerx <= 1920 && answerx >= 0 %if the x answer is outside the 
    %specified range
        
    xRange = true;
    
    else
        
        xRange = false;
        disp('Please enter a value in the range 0-1920');
         
    end
end 

yRange = false; %not the same as yrange. this is a boolean, but the values 
%should still be within 0 and 1200.
while (~ yRange) %the same loop but to get the Y coordinate instead of X

    yquestion = ['Your Y coordinate? '];
    
    answery = input(yquestion);
    
    if answery <= 1200 && answery >= 0
        
    yRange = true;
    
    else
        
        yRange = false;
        disp('Please enter a value in the range 0-1200');
         
    end
end 

%% Generating the window with the dot
% Opens a grey window.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
%you need this or you get a square instead of a circle
%Will need to remove this later on as it's openGL but can use for this?
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 

% Setting the colour of the dots. It's RGB, but you can also use the 
%black/grey/white that you defined earlier. [0 0 0] = black; 
%[1 0 0] = red; [0 1 0] = green; [0 0 1] = blue; [1 1 1] = white. 
dotColor = black;
 
%Remember that if the dot is drawn at the edge of the screen some of it 
%might not be visible.

dotXpos = answerx; %putting in the coordinate you input earlier for X so 
%that it is actually drawn
dotYpos = answery; %putting in the coordinate you input earlier for Y so 
%that it is actually drawn

% Dot size in pixels
dotSizePix = 10;

% Draw the dot to the screen. For information on the command used in
% this line type "Screen DrawDots?" at the command line (without the
% brackets) and press enter. Here we used good antialiasing to get nice
% smooth edges
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);

% Flip to the screen. This command basically draws all of our previous
% commands onto the screen. See later demos in the animation section on more
% timing details. And how to demos in this section on how to draw multiple
% rects at once.
% For help see: Screen Flip?
Screen('Flip', window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo. For help see: help KbStrokeWait
KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;