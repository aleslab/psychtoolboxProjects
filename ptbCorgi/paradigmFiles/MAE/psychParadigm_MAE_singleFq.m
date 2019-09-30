function [conditionInfo, expInfo] = psychParadigm_MAE_singleFq(expInfo)
% adaptation using only one adaptor (not overlapping)



% 8 times 5 s tests per adaptation block (2 tests x 4)
% 20 s + 8*15s = 2.5 min per blk = around 1h
% 12 test conditions 
% 6 adaptor conditions repeated 4 times = 24 blocks (192 trials)
% 1 test 4.7s = 0.47 removed + 20/85*6 (1.4s epoch) * 3
% would do 48 epochs per test condition

% add a noise frame around to increase the strengh of the MAE?

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAE_singleFq';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'adaptorNb';
expInfo.trialRandomization.nBlockReps   = 5;


% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

expInfo.fixationInfo(2).type  = 'cross';
expInfo.fixationInfo(2).size  = .4;
expInfo.fixationInfo(2).lineWidthPix = 3;
expInfo.fixationInfo(2).color = 0;
expInfo.fixationInfo(2).loc = [0 -7]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)
expInfo.fixationInfo(1).type = 'noiseFrame';
expInfo.fixationInfo(1).size = 4;

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).iti = 0;
conditionInfo(1).nReps = 3; % 3 nb of tests in one adaptation block (x3 because there are 3 types of test stimuli per adaptor)
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAE_singleFq;
conditionInfo(1).stimSize = 24; % grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).yEccentricity = 3;
conditionInfo(1).tempFq = 85/18; % 85/18 or 85/16? 4.72 Hz 
conditionInfo(1).testFreq = 85/20; % 4.25 Hz
conditionInfo(1).testDuration = 21; % in cycles. 5 seconds = 20/85*20 cycles (exactly 4.7 seconds)
% add one cycle because real refresh is 0.01176 not 0.0118 so I miss some
% data at the end of the trial...
conditionInfo(1).adaptDuration = 2; % in sec: 10s top-up
conditionInfo(1).longAdapt = 2; % 20 sec added to top-up for the 1st trial

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


%%%% specify the conditions 

conditionTemplate = conditionInfo(1); %Take the first condition as the template
conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
    'testPhase',[90 10 90 90 170 90 90 10 90 90 10 90],...
    'f1',[2 2 2 2 2 2 2 2 2 0.125 0.125 0.125],...
    'direction',[180 180 180 0 0 0 99 99 99 0 0 0],...
    'f2',[0 0 0.5 0 0 0.5 0 0 0.5 0 0 0.5]);

adaptorType = {'rightH','rightH','rightH','leftH','leftH','leftH',...
    'noH','noH','noH','leftL','leftL','leftL'};
numCond = repmat(1:4,3,1);
numCond = numCond(:);
for aa = 1:length(conditionInfo)
    conditionInfo(aa).adaptor = adaptorType(aa);
    conditionInfo(aa).adaptorNb = numCond(aa);
end

% group conditions by adaptation condition
expInfo.conditionGroupingField = 'adaptorNb';


% spatialFq = [0.125 2]; % standard fq 0.5 /4 or *4
% phase = [10 90]; % cannot use a 180 (counterphase) because there is no clear energy motion direction for the SSVEP. 
% % with 180 there is no 1st harmonic which is the one showing a direction
% % selective response
% standardDirection = [0 180 99]; % of standard 0=left, 180=right, 99=none (no drift)
% 
% conditionTemplate = conditionInfo(1); %Take the first condition as the template
% conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
%    'testPhase',phase, 'f2',spatialFq,'direction',standardDirection);
% 
% % there must be a better way but being lazy here
% adaptorType = {'leftSlow','leftSlow','leftFast','leftFast',...
%     'rightSlow','rightSlow','rightFast','rightFast','staticSlow','staticSlow','staticFast','staticFast'};
% numCond = repmat(1:6,2,1);
% numCond = numCond(:);
% for aa = 1:length(conditionInfo)
%     conditionInfo(aa).adaptor = adaptorType(aa);
%     conditionInfo(aa).adaptorNb = numCond(aa);
% end

% f1 = [2 2 2 2 2 2 2 ...
%     2 2 2 0.125 0.125];
% spatialFq = [0 0 0 0 0 0 0 ...
%     0.5 0 0.5 0 0];
% phase = [90 10 90 170 90 10 170 ...
%     90 90 90 10 170];
% standardDirection = [180 180 0 0 99 99 99 ...
%     180 0 180 180 180];
% condName = {'rightH90','rightH10','leftH90','leftH170','noH90','noH10','noH170',...
%     'rightH90double','rightD90','rightD90double','leftL10','leftL170'};
% adaptorNb = [1 1 2 2 3 3 3 1 4 4 5 5];
% 
% for aa=1:12
%     conditionInfo(aa) = conditionInfo(1);
%     conditionInfo(aa).adaptor = adaptorType(aa);
%     conditionInfo(aa).testphase = phase(aa);
%     conditionInfo(aa).f2 = spatialFq(aa);
%     conditionInfo(aa).f1 = f1(aa);
%     conditionInfo(aa).direction = standardDirection(aa);
%     conditionInfo(aa).label = condName(aa);
%     conditionInfo(aa).adaptorNb = adaptorNb(aa);
% end
% 
% % group conditions by adaptation condition
% expInfo.conditionGroupingField = 'adaptorNb';


end
