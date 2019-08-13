function [conditionInfo, expInfo] = psychParadigm_testMAE(expInfo)


KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'testMAE';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'testPhase'; 
expInfo.trialRandomization.nBlockReps   = 1; 

expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_testMAE;
conditionInfo(1).stimSize = 8; % Half-Size of the grating image in degrees
conditionInfo(1).yEccentricity = 5;
conditionInfo(1).speed = 2;

%%%%%%%%%%%% parameters for the different conditions
% spatial freq of the 2 gratings
conditionInfo(1).f1 = 0.005;
conditionInfo(1).f2 = 0.008;
% direction of the 2 gratings 
conditionInfo(1).angle1=0;
conditionInfo(1).angle2=180;
% test grating properties
conditionInfo(1).testFreq = 85/40; % Hz
conditionInfo(1).testPhase = 2; % for now it is moving

end
