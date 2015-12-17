function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc(expInfo)

stimType = input('Please input the stimulus type\n','s');
possibleStimTypes = {'cd','looming','combined'}; 
if ~strcmp(stimType, possibleStimTypes)
    disp('Invalid stimulus type ');
    stimType = input('Please re-enter the stimulus type\n','s');
end

%function [conditionInfo, screenInfo] = MoveLineTrial(screenInfo)
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine';
expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
%Let's use kbQueue's because they have high performance.
%screenInfo.useKbQueue = true;

expInfo.instructions = 'Which one moved slower?\nPress any key to begin';


%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
%Condition 1 is the target absent condition.
conditionInfo(1).type             = '2afc'; 
conditionInfo(1).stimType         = stimType; 
%changing disparity only = cd; looming only = 'looming'; combined = 'combined';
conditionInfo(1).stimDuration     = 5; %0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 5;    %Post trial window for waiting for a response
conditionInfo(1).cmDistance = -25; %distance the line should move in depth in cm 
conditionInfo(1).velocityCmPerSec = conditionInfo(1).cmDistance/conditionInfo(1).stimDuration;  
%Stimulus velocity in cm/s for condition 1 is 5cm/s
%For when there is one vertical line (cd)
conditionInfo(1).startPos = 0; %where on the x axis of the screen the line
%I've changed this to 1 so that this is in cm as it makes it a bit easier
%-- but it means I need to change stuff later on.
%should start at (in pixels)
%For when there are two vertical lines (combined)
conditionInfo(1).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(1).objectTwoStartPos = 1; %the start position of the second line in each eye
%For when there are two horizontal lines (looming)
%This is the start position (+ = above fixation, - = below)of the first line in each eye. 
conditionInfo(1).horizontalOneStartPos = 1; %a y coordinate. the others are x. 
conditionInfo(1).horizontalTwoStartPos = -1;

conditionInfo(1).nReps = 5; %number of repeats

%Now let's create the null that this will be compared with in the 2afc
%trial.  First we copy all the paramaters.
nullCondition = conditionInfo(1);
%Then we change the  parameter of interest:
nullCondition.cmDistance = -57; %distance the line should move in cm
nullCondition.velocityCmPerSec = nullCondition.cmDistance/nullCondition.stimDuration;  
%finally, assign it as the null for condition 1. 
conditionInfo(1).nullCondition = nullCondition;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).cmDistance = -50;
conditionInfo(2).velocityCmPerSec = conditionInfo(2).cmDistance/conditionInfo(2).stimDuration; 
%velocity in cm/s for condition 2 is 10cm/s


conditionInfo(3) = conditionInfo(1);
conditionInfo(3).cmDistance = -37.5;
conditionInfo(3).velocityCmPerSec = conditionInfo(3).cmDistance/conditionInfo(3).stimDuration; 
%velocity in cm/s for condition 3 is 7.5cm/s



