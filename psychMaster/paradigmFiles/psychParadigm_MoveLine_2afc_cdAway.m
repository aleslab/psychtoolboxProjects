function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_cdAway(expInfo)

%Paradigm file for the cd stimulus. One vertical line moving in each eye.
%paradigmName is what will be prepended to data files
expInfo = moveLineDefaultSettings(expInfo);

expInfo.paradigmName = 'MoveLine_cd_away';
%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).type             = '2afc'; 
conditionInfo(1).stimType         = 'cd'; 
conditionInfo(1).stimDurationSection1 = 0.50; %approximate "1st half of stimulus" duration in seconds
conditionInfo(1).stimDurationSection2 = 0.50; %2nd stimulus half duration in seconds
conditionInfo(1).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(1).velocityCmPerSecSection1 = 20; %cm/s - 5cm in section 1
conditionInfo(1).velocityCmPerSecSection2 = 20; %cm/s - 5cm in section 2; 10cm total
conditionInfo(1).isNullCorrect = false; %because the condition is slower
conditionInfo(1).startPos = 0; %start position of the line
conditionInfo(1).nReps = 10; %number of repeats
conditionInfo(1).giveFeedback = false;
conditionInfo(1).depthStart = -10; %5cm behind the plane of the screen
%Now let's create the null that this will be compared with in the 2afc
%trial.  First we copy all the paramaters.
nullCondition = conditionInfo(1);
%Then we change the  parameter of interest:
%nullCondition.cmDistance = -10; %distance the line should move in cm
nullCondition.velocityCmPerSecSection1 = 20;  
nullCondition.velocityCmPerSecSection2 = 20;
%finally, assign it as the null for condition 1. 
conditionInfo(1).nullCondition = nullCondition;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).velocityCmPerSecSection1 = 22.5; %cm/s - 5.625cm in section 1
conditionInfo(2).velocityCmPerSecSection2 = 17.5; %4.375cm in section 2, 10cm total

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).velocityCmPerSecSection1 = 25; %cm/s - 6.25cm in section 1
conditionInfo(3).velocityCmPerSecSection2 = 15; %3.75cm in section 2, 10cm total


conditionInfo(4) = conditionInfo(1);
conditionInfo(4).velocityCmPerSecSection1 = 27.5; %cm/s - 6.875cm in section 1
conditionInfo(4).velocityCmPerSecSection2 = 12.5; %3.125cm in section 2, 10cm total


conditionInfo(5) = conditionInfo(1);
conditionInfo(5).velocityCmPerSecSection1 = 30; %cm/s - 7.5cm in section 1
conditionInfo(5).velocityCmPerSecSection2 = 10; %2.5cm in section 2, 10cm total


conditionInfo(6) = conditionInfo(1);
conditionInfo(6).velocityCmPerSecSection1 = 32.5; %cm/s - 8.125cm in section 1
conditionInfo(6).velocityCmPerSecSection2 = 7.5; %1.875cm in section 2, 10cm total


conditionInfo(7) = conditionInfo(1);
conditionInfo(7).velocityCmPerSecSection1 = 35; %cm/s - 8.75cm in section 1
conditionInfo(7).velocityCmPerSecSection2 = 5; %1.25cm in section 2, 10cm total


