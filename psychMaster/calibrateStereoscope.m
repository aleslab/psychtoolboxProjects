ListenChar(2);
screens = Screen('Screens');

screenNumber = max(screens);

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber);

xcentre = screenXpixels/2;
ycentre = screenYpixels/2;
leftxcentre = xcentre/2;
rightxcentre = xcentre + xcentre/2;

fixCrossDimPix = 200; %the size of the arms of our fixation cross
fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0]; %fixation cross x coordinates
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix]; %fixation cross y coordinates
FixCoords = [fixXCoords; fixYCoords]; %combined fixation cross coordinates
boxCoords1 = [-fixCrossDimPix fixCrossDimPix; fixCrossDimPix fixCrossDimPix];
boxCoords2 = [fixCrossDimPix fixCrossDimPix; fixCrossDimPix -fixCrossDimPix];
boxCoords3 = [fixCrossDimPix -fixCrossDimPix; -fixCrossDimPix -fixCrossDimPix];
boxCoords4 = [-fixCrossDimPix -fixCrossDimPix; fixCrossDimPix -fixCrossDimPix];
boxCoordsMajor = [boxCoords1 boxCoords2 boxCoords3 boxCoords4];

boxCoords5 = [-fixCrossDimPix fixCrossDimPix; 0.5*fixCrossDimPix 0.5*fixCrossDimPix];
boxCoords6 = [-fixCrossDimPix fixCrossDimPix; -0.5*fixCrossDimPix -0.5*fixCrossDimPix];
boxCoords7 = [-0.5*fixCrossDimPix -0.5*fixCrossDimPix; -fixCrossDimPix fixCrossDimPix];
boxCoords8 = [0.5*fixCrossDimPix 0.5*fixCrossDimPix; -fixCrossDimPix fixCrossDimPix];
boxCoordsMinor = [boxCoords5 boxCoords6 boxCoords7 boxCoords8];

centreLineCoords = [0 0; -screenYpixels screenYpixels]; %coordinates for a central line

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey); 
Screen('DrawLines', window, FixCoords, 3, [], [leftxcentre ycentre], 0);
Screen('DrawLines', window, FixCoords, 3, [], [rightxcentre ycentre], 0);
Screen('DrawLines', window, centreLineCoords, 3, [], [xcentre ycentre], 0);
Screen('DrawLines', window, boxCoordsMajor, 3, [], [leftxcentre ycentre], 0);
Screen('DrawLines', window, boxCoordsMajor, 3, [], [rightxcentre ycentre], 0);
Screen('DrawLines', window, boxCoordsMinor, 1, [], [leftxcentre ycentre], 0);
Screen('DrawLines', window, boxCoordsMinor, 1, [], [rightxcentre ycentre], 0);
Screen('Flip', window);
KbStrokeWait;
sca
ListenChar(0);



