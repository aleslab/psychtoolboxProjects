function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_combined(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
%paradigmName is what will be prepended to data files
expInfo = moveLineDefaultSettings(expInfo);

expInfo.paradigmName = 'MoveLine_combined_towards';
%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).type             = '2afc'; 
conditionInfo(1).stimType         = 'combined'; 
conditionInfo(1).stimDurationSection1 = 0.125; %0.5; %approximate stimulus duration in seconds
conditionInfo(1).stimDurationSection2 = 0.125;
conditionInfo(1).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change 
%may need to reintroduce something for post stimduration because it can get confusing when doing the experiment
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 3;    %Post trial window for waiting for a response
%conditionInfo(1).cmDistance = -1; %10% of null
conditionInfo(1).velocityCmPerSecSection1 = 40; %cm/s - 5cm in section 1
conditionInfo(1).velocityCmPerSecSection2 = 40; %cm/s - 5cm in section 2; 10cm total
conditionInfo(1).isNullCorrect = false;
conditionInfo(1).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(1).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(1).nReps = 30; %number of repeats

%Now let's create the null that this will be compared with in the 2afc
%trial.  First we copy all the paramaters.
nullCondition = conditionInfo(1);
%Then we change the  parameter of interest:
%nullCondition.cmDistance = -10; %distance the line should move in cm
nullCondition.velocityCmPerSecSection1 = 40;  
nullCondition.velocityCmPerSecSection2 = 40;
%finally, assign it as the null for condition 1. 
conditionInfo(1).nullCondition = nullCondition;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).velocityCmPerSecSection1 = 45; %cm/s - 5.625cm in section 1
conditionInfo(2).velocityCmPerSecSection2 = 35; %4.375cm in section 2, 10cm total

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).velocityCmPerSecSection1 = 50; %cm/s - 6.25cm in section 1
conditionInfo(3).velocityCmPerSecSection2 = 30; %3.75cm in section 2, 10cm total


conditionInfo(4) = conditionInfo(1);
conditionInfo(4).velocityCmPerSecSection1 = 55; %cm/s - 6.875cm in section 1
conditionInfo(4).velocityCmPerSecSection2 = 25; %3.125cm in section 2, 10cm total


conditionInfo(5) = conditionInfo(1);
conditionInfo(5).velocityCmPerSecSection1 = 60; %cm/s - 7.5cm in section 1
conditionInfo(5).velocityCmPerSecSection2 = 20; %2.5cm in section 2, 10cm total


conditionInfo(6) = conditionInfo(1);
conditionInfo(6).velocityCmPerSecSection1 = 65; %cm/s - 8.125cm in section 1
conditionInfo(6).velocityCmPerSecSection2 = 15; %1.875cm in section 2, 10cm total


conditionInfo(7) = conditionInfo(4);
conditionInfo(7).velocityCmPerSecSection1 = 70; %cm/s - 8.75cm in section 1
conditionInfo(7).velocityCmPerSecSection2 = 10; %1.25cm in section 2, 10cm total


