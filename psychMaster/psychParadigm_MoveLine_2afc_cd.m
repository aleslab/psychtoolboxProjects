function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_cd(expInfo)

%Paradigm file for the cd stimulus. One vertical line moving in each eye.
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_cd';
expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
%Let's use kbQueue's because they have high performance.
%screenInfo.useKbQueue = true;

expInfo.instructions = 'Which one moved slower?\nPress any key to begin';

%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@MoveLineTrial;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).type             = '2afc'; 
conditionInfo(1).stimType         = 'cd'; 
conditionInfo(1).stimDuration     = 5; %0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time after stimulus change
conditionInfo(1).iti              = 1;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 5;    %Post trial window for waiting for a response
conditionInfo(1).cmDistance = -54.15; %distance the line should move in depth in cm -- currently hardcoded as 95% of null
conditionInfo(1).velocityCmPerSec = conditionInfo(1).cmDistance/conditionInfo(1).stimDuration;  %Is -11.4*0.95 = 10.83

conditionInfo(1).startPos = 0; %start position of the line

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
conditionInfo(2).velocityCmPerSec = nullCondition.velocityCmPerSec*0.90; 
%velocity is 10% less than in the first condition. Made the first condition
%so that it is equal to the null condition.


conditionInfo(3) = conditionInfo(1);
conditionInfo(3).velocityCmPerSec = nullCondition.velocityCmPerSec*0.80; 
%velocity is 20% less than condition 1 and the null

%right now psychMaster is still coded that the null will always be the
%fastest and that's the correct answer. We need to change it so that if
%the condition is faster than the null then that's the correct answer...
%but if it's slower then the null is the correct answer. To do this you
%won't be able to have condition 1 as the same as the null trial velocity
%so will have to change that. 

