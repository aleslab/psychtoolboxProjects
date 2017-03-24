function [conditionInfo, expInfo] = Movie_paradigm(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
expInfo.stereoMode = 8;

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'Movie_paradigm';
expInfo.writeMovie = true;
%% conditions
sf = 1;
firstVelocities = [-40:5:-10]/sf;
condStimTypes = repmat( {'lateralCombined'},1,7);

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
conditionInfo(iCond).velocityCmPerSecSection2 = (-80/sf)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 10; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 20/sf; 
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

conditionInfo(iCond).movieString = '';
%defining the null condition
nullCondition = conditionInfo(iCond); %setting it to be the same as other conditions
nullCondition.velocityCmPerSecSection1 = -40/sf;  %then always setting the velocity to be the standard
nullCondition.velocityCmPerSecSection2 = -40/sf; %in both sections
nullCondition.stimType = condStimTypes(iCond); %determining the stimulus type
conditionInfo(iCond).nullCondition = nullCondition; %putting it as a field to be accessed within the condition info struct
conditionInfo(iCond).nullCondition.movieString = 'null';
end

