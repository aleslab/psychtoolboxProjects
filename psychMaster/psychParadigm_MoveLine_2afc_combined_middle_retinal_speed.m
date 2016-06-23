function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_combined_middle_retinal_speed(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_combined_constant_retinal_speed_middle';

%% conditions
firstVelocities = [1.343 0.898 0.744 0.600 0.465 0.337 0.217];
%for speed changes of 0, +/-0.142, +/-0.218, +/-0.291, +/-0.363, +/-0.433,
%+/- 0.501
condStimTypes = repmat({'combined_retinal'},1,7);

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
conditionInfo(iCond).velocityCmPerSecSection2 = (2.686)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -1.671; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = 0.329; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 30; %number of repeats
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 0; %5cm behind the plane of the screen
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

nullCondition = conditionInfo(iCond);
nullCondition.velocityCmPerSecSection1 = 1.343;  
nullCondition.velocityCmPerSecSection2 = 1.343;
nullCondition.stimType = condStimTypes(iCond); 
conditionInfo(iCond).nullCondition = nullCondition;

end