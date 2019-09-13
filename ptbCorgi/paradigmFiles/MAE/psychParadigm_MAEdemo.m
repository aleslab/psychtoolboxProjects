function [conditionInfo, expInfo] = psychParadigm_MAEdemo(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAEdemo';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'adaptorNb';
expInfo.trialRandomization.nBlockReps   = 4;


% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

% for LCD monitor
expInfo.screenNum = 0;
expInfo.requestedResolution.width = 1920;
expInfo.requestedResolution.height = 1080;
expInfo.requestedResolution.hz = 60;
expInfo.requestedResolution.pixelSize = 24;
expInfo.skipCalib = 1;
    
expInfo.fixationInfo(2).type  = 'cross';
expInfo.fixationInfo(2).size  = .4;
expInfo.fixationInfo(2).lineWidthPix = 3;
expInfo.fixationInfo(2).color = 0;
expInfo.fixationInfo(2).loc = [0 -5]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)
expInfo.fixationInfo(1).type = 'noiseFrame';
expInfo.fixationInfo(1).size = 2;

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).iti = 0;
conditionInfo(1).nReps = 2; % nb of tests in one adaptation block (x2 because there are 2 types of test stimuli per adaptor)
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAE_grouped;
conditionInfo(1).stimSize = 16; % grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).yEccentricity = 3;
conditionInfo(1).f1 = 0.5; % in cycle (changes to c/deg in the trial pg)
conditionInfo(1).tempFq = 85/18; % 4.72 Hz 
conditionInfo(1).testFreq = 85/20; % 4.25 Hz
conditionInfo(1).testDuration = 20; % in cycles. 5 seconds = 20/85*20 cycles (exactly 4.7 seconds)
conditionInfo(1).adaptDuration = 10; % in sec: 10s top-up
conditionInfo(1).longAdapt = 20; % 20 sec added to top-up for the 1st trial

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
spatialFq = [0.125 2]; % standard fq 0.5 /4 or *4
phase = [5 90]; % cannot use a 180 (counterphase) because there is no clear energy motion direction for the SSVEP. 
% with 180 there is no 1st harmonic which is the one showing a direction
% selective response
adaptDirection = [0 180]; % of standard 0=left, 180=right, 99=none (no drift)

conditionTemplate = conditionInfo(1); %Take the first condition as the template
conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
   'testPhase',phase, 'f2',spatialFq,'direction',adaptDirection);

% there must be a better way but being lazy here
adaptorType = {'leftSlow','leftSlow','leftFast','leftFast',...
    'rightSlow','rightSlow','rightFast','rightFast','staticSlow','staticSlow','staticFast','staticFast'};
numCond = repmat(1:6,2,1);
numCond = numCond(:);
for aa = 1:length(conditionInfo)
    conditionInfo(aa).adaptor = adaptorType(aa);
    conditionInfo(aa).adaptorNb = numCond(aa);
end

% group conditions by adaptation condition
expInfo.conditionGroupingField = 'adaptorNb';

% % help makeTrialList
% expInfo.trialRandomization.type = 'custom';
% condition = [];
% for blk=1:expInfo.nbBlock
%     condList = Shuffle([repmat(1:22,1,2) 23:44]);
%     new = [condList ;repmat(blk,1,length(condList))];
%     condition = [condition; new'];
% end
% expInfo.trialRandomization.trialList = condition(:,1);
% expInfo.trialRandomization.blockList =  condition(:,2);


% % same parameters in all conditions
% for cc=2:(length(direction)*length(spatialFq)*length(phase))
%     conditionInfo(cc) = conditionInfo(1);
% end
% 
% dir = {'left' 'right' 'none'};
% cond = 1;
% for aa = 1:length(direction)
%     for bb = 1:length(spatialFq)
%         for cc=1:length(phase)
%             conditionInfo(cond).direction = direction(aa);
%             conditionInfo(cond).f2 = spatialFq(bb);
%             conditionInfo(cond).testPhase = phase(cc);
%             conditionInfo(cond).label = [dir{aa} ' sf' num2str(spatialFq(bb)) ' p' num2str(phase(cc))] ;
%             cond = cond+1;
%         end
%     end
% end


end
