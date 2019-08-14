function [conditionInfo, expInfo] = psychParadigm_sweep(expInfo) 

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'sweep';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 18; % 23 blocks, 10 trials, 12 s trial = 46 min 
expInfo.trialRandomization.blockByField = 'yloc';

expInfo.viewingDistance = 57;
 
% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;
expInfo.fixationInfo(1).loc = [0 -4]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE and count the number of dots';

%% General conditions
conditionInfo(1).iti = 0.5; 
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 8; % max time to answer
conditionInfo(1).maxDots = 3; % max number of dots change in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 1 10]; % in deg
nbStimON= 32;
conditionInfo(1).trialDuration = 80*24/85; 
conditionInfo(1).preStimDuration = 2*24/85; 
conditionInfo(1).trialFun=@trial_sweep;
conditionInfo(1).dotSize = [0 0 0.2 0.2];
conditionInfo(1).yloc = 8; % y eccentricity of stim centre
conditionInfo(1).stimTagFreq = 85/8; % for motion, 85/48 for local freq
conditionInfo(1).xMotion = 6;
conditionInfo(1).xloc = -3;
conditionInfo(1).framesOn = 7;

%% experimental manipulation
conditionInfo(1).label = 'stimLum';
conditionInfo(1).motion = 1;
repeatPerContrast = 8;
getVal = repmat([0.45 0.46 0.47 0.48 0.49 0.494 0.495 0.497 0.498],repeatPerContrast,1);
% getVal = repmat([0:0.5/(nbStimON/repeatPerContrast):0.5],repeatPerContrast,1);
getVal = reshape(getVal,[1,size(getVal,1)*size(getVal,2)]);
conditionInfo(1).stimColour = [0 0 getVal 0.5 0.5]; % add values for the pre and post Stim 
% fliplr(conditionInfo(1).stimColour)

% compare with simultaneous (in phase vs out of phase) 
% conditionInfo(2).motion = 0;

% sweep stim contrast



% % same parameters in all conditions
% for cc=2:12
%     conditionInfo(cc) = conditionInfo(1);
% end

% sweep background contrast

% sweep distance between the 2 objects
% conditionInfo(15).xloc = [0.6 6]; % where it starts and ends1
% conditionInfo(15).movingStep = ( conditionInfo(15).xloc(2)-conditionInfo(15).xloc(1) ) / 4; % (conditionInfo(9).trialDuration * conditionInfo(9).stimTagFreq); % distance / nbTotalCycles

% sweep freq?
% sweep DC?

end

