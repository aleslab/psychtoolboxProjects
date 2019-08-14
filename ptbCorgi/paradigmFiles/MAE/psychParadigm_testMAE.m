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
conditionInfo(1).tempFq = 85/17; % checked: this is temporal frequency, not velocity. 5Hz in JoV
% MAE not tunned to velocity but to temporal frequency

%%%%%%%%%%%% parameters for the different conditions
% spatial freq of the 2 gratings
% JoV: The spatial frequency of one of the gratings was always 0.53 c/degree, 
% and the spatial frequency of the other was either 
% 0.13, 0.26, 1.1 or 2.1 c/degree.
conditionInfo(1).f1 = 0.53; % in cycle (changes to c/deg in the trial pg)
conditionInfo(1).f2 = 2.1;
% test grating properties
conditionInfo(1).testFreq = 85/40; % Hz
conditionInfo(1).testPhase = 180; % 180=counterphase 0=static

% note on velocity and temporal freq: 
% 1.25Hz 0.53 c/deg = 2.4 deg/s velocity
% 5Hz 2.1 c/deg = 2.4 deg/s velocity
% 5Hz 0.53 c/deg = 9.4 deg/s velocity


end
