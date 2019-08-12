function [conditionInfo, expInfo] = psychParadigm_testMAE(expInfo)


KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'testMAE';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'adaptation'; 
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

conditionInfo(1).adaptation = 1; 

end
