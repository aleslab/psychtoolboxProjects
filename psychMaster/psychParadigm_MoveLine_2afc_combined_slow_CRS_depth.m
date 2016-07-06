function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc_combined_slow_CRS_depth(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_combined_CRS_depth_slow';

%% conditions
firstVelocities = [0.630 0.488 0.412 0.339 0.267 0.197 0.129];
secondVelocities = [0.630 0.772 0.849 0.922 0.994 1.063 1.131];

condStimTypes = repmat({'combined_retinal_depth'},1,7);

for iCond = 1: length(firstVelocities);
    %general condition definitions
    conditionInfo(iCond).trialFun=@MoveLineTrial; %This defines what function
    %to call to draw the condition
    conditionInfo(iCond).type             = '2afc';
    conditionInfo(iCond).stimType         = condStimTypes{iCond};
    conditionInfo(iCond).isNullCorrect = false;
    conditionInfo(iCond).nReps = 30; %number of repeats
    conditionInfo(iCond).giveFeedback = false;
    conditionInfo(iCond).depthStart = 0; %5cm behind the plane of the screen
    conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))];
    
    %timings
    conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
    conditionInfo(iCond).stimDurationSection2 = 0.50;
    conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
    conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change
    conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
    conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
    
    % line start positions
    conditionInfo(iCond).L1StartPos = -1;
    conditionInfo(iCond).L2StartPos = 1;
    conditionInfo(iCond).R1StartPos = -1;
    conditionInfo(iCond).R2StartPos = 1;
    
    %line velocities
      
    conditionInfo(iCond).L1velocityCmPerSecSection1 = firstVelocities(iCond); %cm/s
    conditionInfo(iCond).L1velocityCmPerSecSection2 = secondVelocities(iCond); %cm/s
    
    conditionInfo(iCond).L2velocityCmPerSecSection1 = firstVelocities(iCond);
    conditionInfo(iCond).L2velocityCmPerSecSection2 = secondVelocities(iCond);
    
    conditionInfo(iCond).R1velocityCmPerSecSection1 = firstVelocities(iCond);
    conditionInfo(iCond).R1velocityCmPerSecSection2 = secondVelocities(iCond);
    
    conditionInfo(iCond).R2velocityCmPerSecSection1 = firstVelocities(iCond);
    conditionInfo(iCond).R2velocityCmPerSecSection2 = secondVelocities(iCond);
    

      %here as a work around this being used by all of the other conditions
      %in MoveLineTrial. Exist doesn't seem to be having the desired
      %effect.
    
    %null condition
    nullCondition = conditionInfo(iCond);
    nullCondition.L1velocityCmPerSecSection1 = 0.63;
    nullCondition.L1velocityCmPerSecSection2 = 0.63;
    
    nullCondition.L2velocityCmPerSecSection1 = 0.63;
    nullCondition.L2velocityCmPerSecSection2 = 0.63;
    
    nullCondition.R1velocityCmPerSecSection1 = 0.63;
    nullCondition.R1velocityCmPerSecSection2 = 0.63;
    
    nullCondition.R2velocityCmPerSecSection1 = 0.63;
    nullCondition.R2velocityCmPerSecSection2 = 0.63;
    
    nullCondition.stimType = condStimTypes(iCond);
    conditionInfo(iCond).nullCondition = nullCondition;
    
end