function [conditionInfo, expInfo] = MoveLine_accelerating_lateral_midspeed(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_accelerating_lateral_midspeed';

%% conditions
firstVelocities = [-40:5:-10];
condStimTypes = repmat( {'lateralCombined'},1,7);

s1lowerspeeds = [0.849 0.745 0.638 0.530 0.426 0.319 0.212];
s1upperspeeds = [1.236 1.027 0.838 0.666 0.508 0.364 0.232];
s2lowerspeeds = [1.239 1.323 1.400 1.467 1.527 1.577 1.625];
s2upperspeeds = [1.961 2.204 2.450 2.695 2.938 3.184 3.427];

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
conditionInfo(iCond).velocityCmPerSecSection2 = (-80)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 10; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 20; %5cm behind the plane of the screen
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

conditionInfo(iCond).lateralCmPerSecS1lower = s1lowerspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS1upper = s1upperspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS2lower = s2lowerspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS2upper = s2upperspeeds(iCond);

%defining the null condition
nullCondition = conditionInfo(iCond); %setting it to be the same as other conditions
nullCondition.velocityCmPerSecSection1 = -40;  %then always setting the velocity to be the standard
nullCondition.velocityCmPerSecSection2 = -40; %in both sections
nullCondition.stimType = condStimTypes(iCond); %determining the stimulus type
conditionInfo(iCond).nullCondition = nullCondition; %putting it as a field to be accessed within the condition info struct

end

