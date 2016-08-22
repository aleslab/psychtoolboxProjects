function [conditionInfo, expInfo] = MoveLine_CRS_depth_midspeed(expInfo)

%Paradigm file for the combined looming and cd stimulus. Two vertical lines
%moving in each eye.
expInfo = moveLineDefaultSettings(expInfo);
%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MoveLine_CRS_depth_midspeed';

%% conditions
firstVelocitiesL1 = [0.896 0.598 0.497 0.398 0.308 0.226 0.141];
secondVelocitiesL1 = [0.896 1.194 1.295 1.394 1.484 1.566 1.645];

firstVelocitiesL2 = [1.790 1.196 0.993 0.799 0.618 0.451 0.288];
secondVelocitiesL2 = [1.790 2.384 2.588 2.782 2.963 3.129 3.287];

firstVelocitiesR1 = [-1.790 -1.196 -0.993 -0.799 -0.618 -0.451 -0.288];
secondVelocitiesR1 = [-1.790 -2.384 -2.588 -2.782 -2.963 -3.129 -3.287];

firstVelocitiesR2 = [-0.896 -0.598 -0.497 -0.398 -0.308 -0.226 -0.141];
secondVelocitiesR2 = [-0.896 -1.194 -1.295 -1.394 -1.484 -1.566 -1.645];

s1depthSpeeds = [49.8 35.8 30.5 25.1 19.9 14.9 9.7];
s2depthSpeeds = [32.3 46.3 51.6 56.9 62.1 67.1 72.3];

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
    conditionInfo(iCond).L1StartPos = -1.3419; %-1 at depth of 117cm, 20cm behind fixation
    conditionInfo(iCond).L2StartPos = 0.3162; %1 at depth of 117cm
    conditionInfo(iCond).R1StartPos = -0.3162; %-1 in depth
    conditionInfo(iCond).R2StartPos = 1.3419; %1 in depth
    
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
    nullCondition.L1velocityCmPerSecSection1 = 0.896;
    nullCondition.L1velocityCmPerSecSection2 = 0.896;
    
    nullCondition.L2velocityCmPerSecSection1 = 1.790;
    nullCondition.L2velocityCmPerSecSection2 = 1.790;
    
    nullCondition.R1velocityCmPerSecSection1 = -1.790;
    nullCondition.R1velocityCmPerSecSection2 = -1.790;
    
    nullCondition.R2velocityCmPerSecSection1 = -0.896;
    nullCondition.R2velocityCmPerSecSection2 = -0.896;
    
    nullCondition.stimType = condStimTypes(iCond);
    conditionInfo(iCond).nullCondition = nullCondition;
    
end