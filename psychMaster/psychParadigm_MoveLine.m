function [conditionInfo, screenInfo] = psychParadigm_MoveLine(screenInfo)


%function [conditionInfo, screenInfo] = MoveLineTrial(screenInfo)
%paradigmName is what will be prepended to data files
screenInfo.paradigmName = 'MoveLine';

%Let's use kbQueue's because they have high performance.
%screenInfo.useKbQueue = true;

screenInfo.instructions = 'Press any key to start';


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
conditionInfo(1).cmDistance = 1; %distance the line should move in cm
conditionInfo(1).velocityCmPerSec = conditionInfo(1).cmDistance/conditionInfo(1).stimDuration;  
%Stimulus velocity in cm/s for condition 1
conditionInfo(1).startPos = 10; %where on the x axis of the screen the line 
%should start at (in pixels)
conditionInfo(1).nReps = 1; %number of repeats

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).cmDistance = 2;
conditionInfo(2).velocityCmPerSec = conditionInfo(2).cmDistance/conditionInfo(2).stimDuration; 
%velocity in cm/s for condition 2


conditionInfo(3) = conditionInfo(1);
conditionInfo(3).cmDistance = 3;
conditionInfo(3).velocityCmPerSec = conditionInfo(3).cmDistance/conditionInfo(3).stimDuration; 
%velocity in cm/s for condition 3

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).cmDistance = 4;
conditionInfo(4).velocityCmPerSec = conditionInfo(4).cmDistance/conditionInfo(4).stimDuration; 
%velocity in cm/s for condition 4

