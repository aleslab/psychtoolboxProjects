function [conditionInfo, expInfo] = MoveLine_accelerating_lateral_slow(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_accelerating_lateral_slow';

%% conditions
firstVelocities = [-20:2.5:-5];
condStimTypes = repmat( {'lateralCombined'},1,7);

%these are the speeds in cm/s on the screen for this condition, as
%calculated using calculateScreenAcceleration
s1lowerspeeds = [0.508 0.446 0.381 0.319 0.254 0.191 0.127];
s1upperspeeds = [0.618 0.528 0.440 0.358 0.280 0.205 0.133];
s2lowerspeeds = [0.618 0.677 0.734 0.787 0.838 0.886 0.934];
s2upperspeeds = [0.767 0.863 0.959 1.0553 1.151 1.247 1.343];

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
conditionInfo(iCond).velocityCmPerSecSection2 = (-40)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).objectOneStartPos = -1; %when there are two lines in each eye, the start position of the first line
conditionInfo(iCond).objectTwoStartPos = 1; %the start position of the second line in each eye
conditionInfo(iCond).nReps = 10; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 10; %5cm behind the plane of the screen
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

conditionInfo(iCond).lateralCmPerSecS1lower = s1lowerspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS1upper = s1upperspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS2lower = s2lowerspeeds(iCond);
conditionInfo(iCond).lateralCmPerSecS2upper = s2upperspeeds(iCond);

%defining the null condition
nullCondition = conditionInfo(iCond); %setting it to be the same as other conditions
nullCondition.velocityCmPerSecSection1 = -20;  %then always setting the velocity to be the standard
nullCondition.velocityCmPerSecSection2 = -20; %in both sections
nullCondition.stimType = condStimTypes(iCond); %determining the stimulus type
conditionInfo(iCond).nullCondition = nullCondition; %putting it as a field to be accessed within the condition info struct

end

