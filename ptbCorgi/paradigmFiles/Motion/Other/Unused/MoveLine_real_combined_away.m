function [conditionInfo, expInfo] = MoveLine_real_combined_away(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
%paradigmName is what will be prepended to data files
expInfo = moveLineDefaultSettings(expInfo);

expInfo.paradigmName = 'MoveLine_real_combined_away';
%% conditions
firstVelocities = [20:2.5:35];
condStimTypes = cat(2, repmat( {'combined'},1,7));

for iCond = 1: length(firstVelocities);
%This defines what function to call to draw the condition
conditionInfo(iCond).trialFun=@MoveLineTrial;

conditionInfo(iCond).type             = '2afc'; 
conditionInfo(iCond).stimType         = condStimTypes{iCond};
conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
conditionInfo(iCond).stimDurationSection2 = 0.50;
conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change 
%may need to reintroduce something for post stimduration because it can get confusing when doing the experiment
conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(iCond).velocityCmPerSecSection1 = firstVelocities(iCond); %cm/s
conditionInfo(iCond).velocityCmPerSecSection2 = (40)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 10; %number of repeats
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = -10; %5cm in front of the plane of the screen
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

nullCondition = conditionInfo(iCond);
nullCondition.velocityCmPerSecSection1 = 20;  
nullCondition.velocityCmPerSecSection2 = 20;
nullCondition.stimType = condStimTypes(iCond); 
conditionInfo(iCond).nullCondition = nullCondition;

end
