function [conditionInfo, expInfo] = SpeedDisc_fixed_duration(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'SpeedDisc_fixed_duration';
expInfo.instructions = 'Which one \nmoved faster?\nPress any key\nto begin';
%% conditions
velocities = [-40:-5:-70];
condStimTypes = repmat( {'looming'},1,9);

for iCond = 1: (length(condStimTypes)-2);
%This defines what function to call to draw the condition
conditionInfo(iCond).trialFun=@MoveLineTrial;

conditionInfo(iCond).type             = '2afc'; 
conditionInfo(iCond).stimType         = condStimTypes{iCond};
conditionInfo(iCond).fixedDistance = false;
conditionInfo(iCond).stimDurationSection1 = 0; %approximate stimulus duration in seconds
conditionInfo(iCond).stimDurationSection2 = 0.5;
conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change 
%may need to reintroduce something for post stimduration because it can get confusing when doing the experiment
conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(iCond).velocityCmPerSecSection1 = 0; %cm/s
conditionInfo(iCond).velocityCmPerSecSection2 = velocities(iCond); %cm/s 
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).horizontalOneStartPos = 1; %a y coordinate. the others are x. 
conditionInfo(iCond).horizontalTwoStartPos = -1;
conditionInfo(iCond).nReps = 10; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).depthStart = 0; 
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(velocities(iCond))];


%defining the null condition
nullCondition = conditionInfo(iCond); %setting it to be the same as other conditions
nullCondition.velocityCmPerSecSection1 = 0;  %then always setting the velocity to be the standard
nullCondition.velocityCmPerSecSection2 = -40; %in both sections
nullCondition.stimType = condStimTypes(iCond); %determining the stimulus type
conditionInfo(iCond).nullCondition = nullCondition; %putting it as a field to be accessed within the condition info struct

end

%condition (level) for catch trials

%balanced catch - response to longer duration = 0% correct; response to longer
%distance = 100% correct; response to speed = 50% correct
conditionInfo(8) = conditionInfo(1);
conditionInfo(8).stimDurationSection2 = 0.750; %different so that duration is longer; 
%attempt to catch use of distance as cue. 
conditionInfo(8).fixedDistance = true;
conditionInfo(8).velocityCmPerSecSection2 = -40;
conditionInfo(8).label = [ condStimTypes{iCond} '_catch_fixed_speed_long_duration'];


% %Slower speed with a fixed duration catch. response to speed = 0%
% correct; response to longer distance = 100% correct, response to shorter
% duration = 0% correct.
conditionInfo(9) = conditionInfo(1);
conditionInfo(9).fixedDistance = true;
conditionInfo(9).velocityCmPerSecSection2 = -20;  
conditionInfo(9).label = [ condStimTypes{iCond} '_catch_slow_speed_long_distance'];



