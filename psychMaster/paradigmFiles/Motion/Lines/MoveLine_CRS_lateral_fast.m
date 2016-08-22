function [conditionInfo, expInfo] = MoveLine_CRS_lateral_fast(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_CRS_lateral_fast';

%% conditions
firstVelocities = [6 2];
condStimTypes = repmat({'combined_retinal_lateral'},1,2);

for iCond = 1: length(firstVelocities);
%This defines what function to call to draw the condition
conditionInfo(iCond).trialFun=@MoveLineTrial;

conditionInfo(iCond).type             = '2afc'; 
conditionInfo(iCond).stimType         = condStimTypes{iCond};
conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
conditionInfo(iCond).stimDurationSection2 = 0.50;
conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change 


conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(iCond).velocityCmPerSecSection1 = firstVelocities(iCond); %cm/s
conditionInfo(iCond).velocityCmPerSecSection2 = (16)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -5; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = -3; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 30; %number of repeats
conditionInfo(iCond).giveAudioFeedback = false;
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 0; %5cm behind the plane of the screen
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

nullCondition = conditionInfo(iCond);
nullCondition.velocityCmPerSecSection1 = 8;  
nullCondition.velocityCmPerSecSection2 = 8;
nullCondition.stimType = condStimTypes(iCond); 
conditionInfo(iCond).nullCondition = nullCondition;

end