function [conditionInfo, expInfo] = MoveLine_CRS_depth_slow(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_CRS_depth_slow';

%% conditions
firstVelocitiesL1 = [0.419 0.323 0.275 0.226 0.176 0.132 0.087];
secondVelocitiesL1 = [0.419 0.516 0.563 0.612 0.662 0.706 0.751];

firstVelocitiesL2 = [0.839 0.648 0.549 0.451 0.354 0.263 0.173];
secondVelocitiesL2 = [0.839 1.031 1.130 1.227 1.325 1.416 1.506];

firstVelocitiesR1 = [-0.839 -0.648 -0.549 -0.451 -0.354 -0.263 -0.173];
secondVelocitiesR1 = [-0.839 -1.031 -1.130 -1.227 -1.325 -1.416 -1.506];

firstVelocitiesR2 = [-0.419 -0.323 -0.275 -0.226 -0.176 -0.132 -0.087];
secondVelocitiesR2 = [-0.419 -0.516 -0.563 -0.612 -0.662 -0.706 -0.751];

s1depthSpeeds = [22.2 17.5 15.1 12.5 9.9 7.5 5.0];
s2depthSpeeds = [18.0 22.7 25.1 27.7 30.3 32.7 35.2];

condStimTypes = repmat({'combined_retinal_depth'},1,7);

for iCond = 1: length(firstVelocitiesL1);
    %general condition definitions
    conditionInfo(iCond).trialFun=@MoveLineTrial; %This defines what function
    %to call to draw the condition
    conditionInfo(iCond).type             = '2afc';
    conditionInfo(iCond).stimType         = condStimTypes{iCond};
    conditionInfo(iCond).isNullCorrect = false;
    conditionInfo(iCond).nReps = 10; %number of repeats
    conditionInfo(iCond).intervalBeep = true;
    conditionInfo(iCond).giveFeedback = false;
    conditionInfo(iCond).depthStart = 0; %5cm behind the plane of the screen
    conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocitiesL1(iCond))];
    
    %timings
    conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
    conditionInfo(iCond).stimDurationSection2 = 0.50;
    conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
    conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change
    conditionInfo(iCond).iti              = 1;     %Inter Stimulus Interval
    conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
    
    % line start positions
    conditionInfo(iCond).L1StartPos = -1.1869; %-1 at depth of 107cm, 10cm behind fixation
    conditionInfo(iCond).L2StartPos = 0.6262; %1 at depth of 107cm
    conditionInfo(iCond).R1StartPos = -0.6262; %-1 at depth of 107cm
    conditionInfo(iCond).R2StartPos = 1.1869; %1 at 107cm in depth
    
    %line velocities
      
    conditionInfo(iCond).L1velocityCmPerSecSection1 = firstVelocitiesL1(iCond); %cm/s
    conditionInfo(iCond).L1velocityCmPerSecSection2 = secondVelocitiesL1(iCond); %cm/s
    
    conditionInfo(iCond).L2velocityCmPerSecSection1 = firstVelocitiesL2(iCond);
    conditionInfo(iCond).L2velocityCmPerSecSection2 = secondVelocitiesL2(iCond);
    
    conditionInfo(iCond).R1velocityCmPerSecSection1 = firstVelocitiesR1(iCond);
    conditionInfo(iCond).R1velocityCmPerSecSection2 = secondVelocitiesR1(iCond);
    
    conditionInfo(iCond).R2velocityCmPerSecSection1 = firstVelocitiesR2(iCond);
    conditionInfo(iCond).R2velocityCmPerSecSection2 = secondVelocitiesR2(iCond);
    
    conditionInfo(iCond).depthSpeedSection1 = s1depthSpeeds(iCond);
    conditionInfo(iCond).depthSpeedSection2 = s2depthSpeeds(iCond);
    
    %null condition
    nullCondition = conditionInfo(iCond);
    nullCondition.L1velocityCmPerSecSection1 = 0.419;
    nullCondition.L1velocityCmPerSecSection2 = 0.419;
    
    nullCondition.L2velocityCmPerSecSection1 = 0.839;
    nullCondition.L2velocityCmPerSecSection2 = 0.839;
    
    nullCondition.R1velocityCmPerSecSection1 = -0.839;
    nullCondition.R1velocityCmPerSecSection2 = -0.839;
    
    nullCondition.R2velocityCmPerSecSection1 = -0.419;
    nullCondition.R2velocityCmPerSecSection2 = -0.419;
    
    nullCondition.stimType = condStimTypes(iCond);
    conditionInfo(iCond).nullCondition = nullCondition;
    
end