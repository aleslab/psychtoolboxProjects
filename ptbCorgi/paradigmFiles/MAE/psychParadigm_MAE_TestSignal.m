function [conditionInfo, expInfo] = psychParadigm_MAE_TestSignal(expInfo)
% Only 6 conditions, each with 30 s adaptation 5 s test
% test high spatial fq grating at 90 or 5 deg phase
% NO overlapping grating

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAE_testSignal';
expInfo.viewingDistance = 57;
% expInfo.trialRandomization.type = 'blocked';
% expInfo.trialRandomization.blockByField = 'adaptorNb';
% expInfo.trialRandomization.nBlockReps   = 4;


expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;
% expInfo.useBitsSharp = false; 
% expInfo.enableTriggers = false;

expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .4;
expInfo.fixationInfo(1).lineWidthPix = 3;
expInfo.fixationInfo(1).color = 0;
expInfo.fixationInfo(1).loc = [0 0]; % [0 -5]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).maxToAnswer = 3;
conditionInfo(1).iti = 0;
conditionInfo(1).nReps = 16; %
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAE_TestSignal;
conditionInfo(1).stimSize = 24; % grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).yEccentricity = 7;
conditionInfo(1).f1 = 1; % 0.25 or 1 (standard is 0.5) % in cycle (changes to c/deg in the trial pg)
conditionInfo(1).tempFq = 85/18; % 85/18 or 85/16? 4.72 Hz 
conditionInfo(1).testFreq = 85/20; % 4.25 Hz
conditionInfo(1).testDuration = 21; % in cycles. 5 seconds = 20/85*20 cycles (exactly 4.7 seconds)
% add one cycle because real refresh is 0.01176 not 0.0118 so I miss some
% data at the end of the trial...
conditionInfo(1).adaptDuration = 30; % in s
% conditionInfo(1).longAdapt = 20;

%%%%%%%%%%%% parameters for the different conditions
% spatial freq of the 2 gratings
% JoV: The spatial frequency of one of the gratings was always 0.53 c/degree, 
% and the spatial frequency of the other was either 
% 0.13, 0.26, 1.1 or 2.1 c/degree.

% note on velocity and temporal freq: 
% 1.25Hz 0.53 c/deg = 2.4 deg/s velocity
% 5Hz 2.1 c/deg = 2.4 deg/s velocity
% 5Hz 0.53 c/deg = 9.4 deg/s velocity

% tempFq checked: this is temporal frequency, not velocity. 5Hz in JoV
% MAE not tunned to velocity but to temporal frequency


% %%% fully random trials
% expInfo.trialRandomization.trialList = Shuffle(repmat(1:12,1,2));% 12 trials repeated 2 times
% expInfo.trialRandomization.blockList = 1:length(expInfo.trialRandomization.trialList); % one trial per block


% spatialFq = [0.13 0.26 1.1 2.1];
% spatialFq = [0.25 1]; % standard fq 0.5 /4 or *4
% spatialFq = [0.125 2]; % standard fq 0.5 /4 or *4
% spatialFq = 1; % 0.25 or 1 (standard is 0.5)
phase = [10 90]; % cannot use a 180 (counterphase) because there is no clear energy motion direction for the SSVEP. 
% with 180 there is no 1st harmonic which is the one showing a direction
% selective response
standardDirection = [0 180 99]; % of standard 0=left, 180=right, 99=none (no drift)

conditionTemplate = conditionInfo(1); %Take the first condition as the template
conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
   'testPhase',phase, 'direction',standardDirection);

% % there must be a better way but being lazy here
% adaptorType = {'left','left','right','right','static','static'};
% numCond = repmat(1:3,2,1);
% numCond = numCond(:);
% for aa = 1:length(conditionInfo)
%     conditionInfo(aa).adaptor = adaptorType(aa);
%     conditionInfo(aa).adaptorNb = numCond(aa);
% end

% group conditions by adaptation condition
% expInfo.conditionGroupingField = 'adaptorNb';



% %%%% specify the conditions 
% expInfo.trialRandomization.nBlockReps   = 1;
% conditionTemplate = conditionInfo(1); %Take the first condition as the template
% conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
%     'testPhase',[90 10],...
%     'direction',[0 180 99],...
%     'f2',[0.125 2]);
% 
% adaptorType = {'leftSlow','leftSlow','leftFast','leftFast',...
%     'rightSlow','rightSlow','rightFast','rightFast','staticSlow','staticSlow','staticFast','staticFast'};
% numCond = [1 1 2 2 3 3 4 4 5 5 6 6];
% for aa = 1:length(conditionInfo)
%     conditionInfo(aa).adaptor = adaptorType(aa);
%     conditionInfo(aa).adaptorNb = numCond(aa);
% end
% 
% % group conditions by adaptation condition
% expInfo.conditionGroupingField = 'adaptorNb';




end






