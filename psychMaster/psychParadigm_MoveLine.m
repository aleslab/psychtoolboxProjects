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
% conditionInfo(1).sigma=.2;
% conditionInfo(1).freq = 4;

conditionInfo(1).velocityCmPerSec = 2;  %Stimulus velocity
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
