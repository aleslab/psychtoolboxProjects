function [conditionInfo, expInfo] = driftGrating_fast(expInfo)

expInfo = moveLineDefaultSettings(expInfo); %contains information for the 
%stereomode, viewing distance and information that should be displayed at 
%the beginning of the experiment and when paused. The same information is 
%needed for the drifting sinusoidal grating experiments as the moving line 
%experiments, so it makes sense to use this here.

expInfo.paradigmName = 'driftGrating_fast';

%% conditions
firstVelocities = [6 2];
condStimTypes = repmat( {'grating'},1,2);

for iCond = 1: length(firstVelocities);
    %general
conditionInfo(iCond).trialFun=@driftSineGratingTrial; %This defines what 
%function to call to draw the condition
conditionInfo(iCond).type             = '2afc'; 
conditionInfo(iCond).stimType         = condStimTypes(iCond);

%timings and speeds
conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
conditionInfo(iCond).stimDurationSection2 = 0.50;
conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(iCond).velocityCmPerSecSection1 = firstVelocities(iCond); %cm/s
conditionInfo(iCond).velocityCmPerSecSection2 = (16)-(conditionInfo(iCond).velocityCmPerSecSection1); %cm/s 

%sine wave grating structure
conditionInfo(iCond).degPerCycle = 1;
conditionInfo(iCond).degGratingSize = 4;
conditionInfo(iCond).xOffset = 0;

%repeats, which is correct, feedback, labelling etc.
conditionInfo(iCond).isNullCorrect = false;
conditionInfo(iCond).nReps = 30; %number of repeats
conditionInfo(iCond).intervalBeep = true;
conditionInfo(iCond).giveAudioFeedback = false;
conditionInfo(iCond).giveFeedback = false;
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];

%standard (null) condition
nullCondition = conditionInfo(iCond);
nullCondition.velocityCmPerSecSection1 = 8;  
nullCondition.velocityCmPerSecSection2 = 8;
nullCondition.stimType = condStimTypes(iCond); 
conditionInfo(iCond).nullCondition = nullCondition;

end