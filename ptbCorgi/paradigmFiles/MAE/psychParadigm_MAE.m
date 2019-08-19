function [conditionInfo, expInfo] = psychParadigm_MAE(expInfo)
% 5 times 5 s tests per block, each block repeated 3 times
% 12 conditions
% 30 epochs of 2 s per condition
% 1h+ session

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAE';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'direction'; 
expInfo.trialRandomization.nBlockReps = 3; 

expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;
expInfo.fixationInfo(1).loc = [0 -5]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAE;
conditionInfo(1).stimSize = 8; % Half-Size of the grating image in degrees
conditionInfo(1).yEccentricity = 3;
conditionInfo(1).f1 = 0.53; % in cycle (changes to c/deg in the trial pg)
conditionInfo(1).tempFq = 85/17; % 5 Hz
conditionInfo(1).testFreq = 85/21; % 4 Hz 
conditionInfo(1).vblAdaptTopUP = 3; % re-adaptation 10 seconds
conditionInfo(1).vblTestDuration = 2; % test duration 5 seconds 
conditionInfo(1).adaptDuration = 2; % % Adaptation duration 30 s
conditionInfo(1).nbRepeat = 4; % in addition to the first adaptation

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



% spatialFq = [0.13 0.26 1.1 2.1];
spatialFq = [0.13 2.1];
phase = [5 90];
direction = [0 180 99]; % of standard 0=left, 180=right, 99=none (no drift)

% same parameters in all conditions
for cc=2:(length(direction)*length(spatialFq)*length(phase))
    conditionInfo(cc) = conditionInfo(1);
end

dir = {'left' 'right' 'none'};
cond = 1;
for aa = 1:length(direction)
    for bb = 1:length(spatialFq)
        for cc=1:length(phase)
            conditionInfo(cond).direction = direction(aa);
            conditionInfo(cond).f2 = spatialFq(bb);
            conditionInfo(cond).testPhase = phase(cc);
            conditionInfo(cond).label = [dir{aa} ' sf' num2str(spatialFq(bb)) ' p' num2str(phase(cc))] ;
            cond = cond+1;
        end
    end
end


end