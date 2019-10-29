function [conditionInfo, expInfo] = psychParadigm_MAE_compare(expInfo)
% compare Justin's parameters with the ones used until now 
% 3 different tests: 
% - 9 Hz fovea 2c/deg
% - 4 Hz fovea 0.5c/deg
% - 9 Hz not fovea 2 c/deg
% 25 s adapt followed by 10 s test
% 3 different tests (blocked) x 9 times each = 27 trials in adaptation
% block x 2 directions + 3x9 trials in unadaptated


KbName('UnifyKeyNames');



conditionInfo(1).direction = 'left';
% choose from none, left, or right adaptation


if strcmp(conditionInfo(1).direction, 'none')
    expInfo.trialRandomization.nBlockReps = 3; 
%     conditionInfo(1).nReps = 3;
else
    expInfo.trialRandomization.nBlockReps = 9;
%     conditionInfo(1).nReps = 9;
end


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAEcomp';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.type = 'custom';
list = repmat(1:3,expInfo.trialRandomization.nBlockReps,1);
expInfo.trialRandomization.trialList  = list(:)';

% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;

expInfo.fixationInfo(1).type  = 'dot';
expInfo.fixationInfo(1).size  = .2; % radius of the dot
expInfo.fixationInfo(1).loc = [0 0]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE the dot';
expInfo.showTrialNb = 1; % give trial nb at the end of each trial (+ wait for keyboard)

conditionInfo(1).maxToAnswer = 10000;
conditionInfo(1).iti = 0;
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAEcomp;
conditionInfo(1).stimSize = 8; % 24 grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).yEccentricity = 3;
conditionInfo(1).tempFq = 85/18; % 85/18 or 85/16? 4.72 Hz 
conditionInfo(1).testDuration = 4; % 42 in cycles. 10 seconds = 20/85*42 cycles
conditionInfo(1).adaptDuration = 1; % in sec: 25


%%%%%%%%%%%% parameters for the different conditions
conditionTemplate = conditionInfo(1); 
conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
    'f1',[2 0.5 2],... % cycle/deg
    'testFreq',[85/10 85/20 85/10],... % Hz
    'fovea',[1 1 0]); % presented at fovea 1 or not 0


end






