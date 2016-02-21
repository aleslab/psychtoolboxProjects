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
conditionInfo(1).stimDurationSection1 = 0.250; %approximate stimulus duration in seconds
conditionInfo(1).stimDurationSection2 = 0.250;
conditionInfo(1).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change 
%may need to reintroduce something for post stimduration because it can get confusing when doing the experiment
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(1).velocityCmPerSecSection1 = -20; %cm/s
conditionInfo(1).velocityCmPerSecSection2 = -20; %cm/s 
conditionInfo(1).isNullCorrect = false;
conditionInfo(1).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(1).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(1).nReps = 30; %number of repeats
conditionInfo(1).giveFeedback = false;
conditionInfo(1).depthStart = 5; %5cm behind the plane of the screen
%Now let's create the null that this will be compared with in the 2afc
%trial.  First we copy all the paramaters.
nullCondition = conditionInfo(1);
nullCondition.stimType = 'combined';
%Then we change the  parameter of interest:
%nullCondition.cmDistance = -10; %distance the line should move in cm
nullCondition.velocityCmPerSecSection1 = -20;  
nullCondition.velocityCmPerSecSection2 = -20;
%finally, assign it as the null for condition 1. 
conditionInfo(1).nullCondition = nullCondition;

%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).velocityCmPerSecSection1 = -22.5; %cm/s - 5.625cm in section 1
conditionInfo(2).velocityCmPerSecSection2 = -17.5; %4.375cm in section 2, 10cm total

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).velocityCmPerSecSection1 = -25; %cm/s - 6.25cm in section 1
conditionInfo(3).velocityCmPerSecSection2 = -15; %3.75cm in section 2, 10cm total


conditionInfo(4) = conditionInfo(1);
conditionInfo(4).velocityCmPerSecSection1 = -27.5; %cm/s - 6.875cm in section 1
conditionInfo(4).velocityCmPerSecSection2 = -12.5; %3.125cm in section 2, 10cm total


conditionInfo(5) = conditionInfo(1);
conditionInfo(5).velocityCmPerSecSection1 = -30; %cm/s - 7.5cm in section 1
conditionInfo(5).velocityCmPerSecSection2 = -10; %2.5cm in section 2, 10cm total


conditionInfo(6) = conditionInfo(1);
conditionInfo(6).velocityCmPerSecSection1 = -32.5; %cm/s - 8.125cm in section 1
conditionInfo(6).velocityCmPerSecSection2 = -7.5; %1.875cm in section 2, 10cm total


conditionInfo(7) = conditionInfo(1);
conditionInfo(7).velocityCmPerSecSection1 = -35; %cm/s - 8.75cm in section 1
conditionInfo(7).velocityCmPerSecSection2 = -5; %1.25cm in section 2, 10cm total

%lateral motion conditions
conditionInfo(8) = conditionInfo(1);
conditionInfo(8).stimType         = 'lateralCombined'; 

conditionInfo(9) = conditionInfo(2);
conditionInfo(9).stimType         = 'lateralCombined'; 

conditionInfo(10) = conditionInfo(3);
conditionInfo(10).stimType         = 'lateralCombined'; 

conditionInfo(11) = conditionInfo(4);
conditionInfo(11).stimType         = 'lateralCombined'; 

conditionInfo(12) = conditionInfo(5);
conditionInfo(12).stimType         = 'lateralCombined'; 

conditionInfo(13) = conditionInfo(6);
conditionInfo(13).stimType         = 'lateralCombined'; 

conditionInfo(14) = conditionInfo(7);
conditionInfo(14).stimType         = 'lateralCombined'; 

if strcmp(conditionInfo(iCond).stimType, 'combined');
    nullCondition.stimType = 'combined';
else
    nullCondition.stimType = 'lateralCombined';
end

 

    


