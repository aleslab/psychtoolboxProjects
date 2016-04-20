function [conditionInfo, expInfo] = psychParadigm_MoveLine_DirectionDiscrimination_cd(expInfo)

%Paradigm file for determining what direction of movement people see when
%presented with stimuli that are programmed to be moving towards, away,
%leftwards or rightwards relative to the observer. This paradigm file is
%for the single vertical line (stereo only) version of this.

expInfo = moveLineDefaultSettings(expInfo);
expInfo.instructions = 'What direction did \nthe stimulus move in?';
expInfo.paradigmName = 'MoveLine_DirectionDiscrimination_cd';
%% conditions
firstVelocities = cat(2,repmat([-20, 20],1,4)); % first section velocities are all 20cms-1 but in different directions
condStimTypes = cat(2, repmat( {'cd'},1,4) , repmat( {'lateralCd'},1,4)); %condition types cd cd lateralCd lateralCd
stimDuration1 = cat(2,repmat([0.25 0.25 0.5 0.5],1,2));
stimDuration2 = stimDuration1;
depthStart = cat(2,repmat([5 -5 10 -10], 1,2));

for iCond = 1: length(firstVelocities);
    
%This defines what function to call to draw the condition
conditionInfo(iCond).trialFun=@MoveLineTrial;

conditionInfo(iCond).type             = 'directionreport'; 
conditionInfo(iCond).stimType         = condStimTypes{iCond}; 
conditionInfo(iCond).stimDurationSection1 = stimDuration1(iCond); %approximate stimulus duration in seconds
conditionInfo(iCond).stimDurationSection2 = stimDuration2(iCond);
conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
conditionInfo(iCond).postStimDuration = 0;  %static time after stimulus change 
%may need to reintroduce something for post stimduration because it can get confusing when doing the experiment
conditionInfo(iCond).responseDuration = 3;    %Post trial window for waiting for a response
conditionInfo(iCond).velocityCmPerSecSection1 = firstVelocities(iCond); %cm/s
conditionInfo(iCond).velocityCmPerSecSection2 = firstVelocities(iCond); %cm/s 
conditionInfo(iCond).startPos = 0;
conditionInfo(iCond).nReps = 30; %number of repeats
conditionInfo(iCond).depthStart = depthStart(iCond); %start position in Z axis
conditionInfo(iCond).label = [ condStimTypes{iCond} '_' num2str(firstVelocities(iCond))]; 
%the label that appears in psychmaster for the condition

end
