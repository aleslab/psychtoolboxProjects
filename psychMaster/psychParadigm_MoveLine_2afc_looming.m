function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_looming(expInfo)

%Paradigm file for the looming stimulus. Two norizontal lines moving in each eye.
%paradigmName is what will be prepended to data files
expInfo = moveLineDefaultSettings(expInfo);

expInfo.paradigmName = 'MoveLine_looming';

%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).type             = '2afc'; 
conditionInfo(1).stimType         = 'looming'; 
conditionInfo(1).stimDuration     = 0.25; %0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(1).cmDistance = -9.5; %distance the line should move in depth in cm -- currently hardcoded as 95% of null
conditionInfo(1).velocityCmPerSec = conditionInfo(1).cmDistance/conditionInfo(1).stimDuration;  %9.5cm/0.25s = 38cm/s
conditionInfo(1).velocityLessThanNull = true;
conditionInfo(1).nReps = 30; %number of repeats
%This is the start position (+ = above fixation, - = below)of the first line in each eye. 
conditionInfo(1).horizontalOneStartPos = 1; %a y coordinate. the others are x. 
conditionInfo(1).horizontalTwoStartPos = -1;

%Now let's create the null that this will be compared with in the 2afc
%trial.  First we copy all the paramaters.
nullCondition = conditionInfo(1);
%Then we change the  parameter of interest:
nullCondition.cmDistance = -10; %distance the line should move in cm
nullCondition.velocityCmPerSec = nullCondition.cmDistance/nullCondition.stimDuration;  
%finally, assign it as the null for condition 1. 
conditionInfo(1).nullCondition = nullCondition;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).velocityCmPerSec = nullCondition.velocityCmPerSec*0.90; 
%velocity is 10% less than in the first condition. Made the first condition
%so that it is equal to the null condition.


conditionInfo(3) = conditionInfo(1);
conditionInfo(3).velocityCmPerSec = nullCondition.velocityCmPerSec*0.80; 
%velocity is 20% less than condition 1 and the null

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).velocityCmPerSec = nullCondition.velocityCmPerSec*1.05; 
%5% faster than the null
conditionInfo(4).velocityLessThanNull = false;

conditionInfo(5) = conditionInfo(4);
conditionInfo(5).velocityCmPerSec = nullCondition.velocityCmPerSec*1.10; 
%10% faster than the null

conditionInfo(6) = conditionInfo(4);
conditionInfo(6).velocityCmPerSec = nullCondition.velocityCmPerSec*1.20; 
%20% faster than the null

