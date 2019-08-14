function [conditionInfo, expInfo] = psychParadigm_behaviourMAE(expInfo)


KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'behaviourMAE';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'stimSize'; 
expInfo.trialRandomization.nBlockReps = 4; 

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
conditionInfo(1).trialFun=@trial_behaviourMAE;
conditionInfo(1).stimSize = 8; % Half-Size of the grating image in degrees
conditionInfo(1).yEccentricity = 5;
conditionInfo(1).f1 = 0.53; % in cycle (changes to c/deg in the trial pg)

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
phase = [0 5 90 180];
tempFq = [85/17 85/42]; % 5 or 2 Hz
testFq = [85/21 85/57]; % 4 or 1.5 Hz 

% same parameters in all conditions
for cc=2:(length(tempFq)*length(spatialFq)*length(phase))
    conditionInfo(cc) = conditionInfo(1);
end

cond = 1;
for aa = 1:length(tempFq)
    for bb = 1:length(spatialFq)
        for cc=1:length(phase)
            conditionInfo(cond).tempFq = tempFq(aa);
            conditionInfo(cond).testFreq = testFq(aa);
            conditionInfo(cond).f2 = spatialFq(bb);
            conditionInfo(cond).testPhase = phase(cc);
            conditionInfo(cond).label = ['tf' num2str(aa) ' sf' num2str(spatialFq(bb)) ' p' num2str(phase(cc))] ;
            cond = cond+1;
        end
    end
end


end
