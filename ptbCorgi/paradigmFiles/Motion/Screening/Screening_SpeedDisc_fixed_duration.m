function [conditionInfo, expInfo] = Screening_SpeedDisc_fixed_duration(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'Screening_SpeedDisc_fixed_duration';
expInfo.instructions = 'Which one \nmoved faster?\nPress any key\nto begin';
%% conditions
condStimTypes = repmat( {'looming'},1,2);
velocities = [-50 -70];
for iCond = 1: length(condStimTypes);
%This defines what function to call to draw the condition
conditionInfo(iCond).trialFun=@MoveLineTrial;

conditionInfo(iCond).type             = '2afc'; 
conditionInfo(iCond).stimType         = condStimTypes{iCond};
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
conditionInfo(iCond).nReps = 15; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveAudioFeedback = true;
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

