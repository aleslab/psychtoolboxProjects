function [conditionInfo, expInfo] = psychParadigm_standardDist(expInfo)
% compare which moves more between a standard and a test stimulus
% all at 5Hz

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'standardDist';
% expInfo.trialRandomization.blockByField = 'xloc'; 
% expInfo.trialRandomization.nBlockReps   = 8; 

                
expInfo.viewingDistance = 57;

expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;
% expInfo.useBitsSharp = true;
expInfo.trialRandomization.type = 'custom';



%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'FIXATE the dot';

%% General conditions
conditionInfo(1).iti = 0.5; % inter-trial-interval
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 999; % next trial starts only after giving an answer % max time to answer
conditionInfo(1).texRect = [0 0 6 12];


%% stimulus
conditionInfo(1).stimSize = [0 0 0.5 10]; % in deg
conditionInfo(1).xlocRef = [-5 -5.5]; % use 2 different numbers for moving stim
conditionInfo(1).dutyCycle =4/8;
% + up to 1 deg to get a random location
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_standardDist_int;
conditionInfo(1).trialDuration = 2*32/85;


%% experimental manipulation

% single stim condition
testedFreq = 85/16; % [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
dist = [0 0.25 0.5 0.75];
ecc = [5];
stimContrast = [1];

% same parameters in all conditions
for cc=2:length(dist)*length(ecc)*length(stimContrast)
    conditionInfo(cc) = conditionInfo(1);
end

condNb = 1;
for sc=1:length(stimContrast)
    for loc=1:length(ecc)
        for testFq=1:length(testedFreq)
            for space=1:length(dist)
                conditionInfo(condNb).stim = stimContrast(sc);
                conditionInfo(condNb).xloc = ecc(loc); % eccentricity of stim centre from screen centre in deg
                conditionInfo(condNb).xMotion = dist(space);
                conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
                conditionInfo(condNb).label = ['S' num2str(sc) '_E' num2str(ecc(loc)) '_D' num2str(dist(space))];
                condNb = condNb+1;
            end
        end
    end
end

%%% make blocks of different stimuli
%%% cannot have low contrast with the other trials
condPerStim = length(conditionInfo)/length(stimContrast);nbRep=60;
allStim = [];
for btype = 1:length(stimContrast)
    allStim = [allStim Shuffle(repmat(1+condPerStim*(btype-1):condPerStim*btype,1,nbRep))];
end
% reshape the long vector into columns
nbBlk = 20; trialPerBlk = length(allStim)/nbBlk;
allStim=reshape(allStim,[trialPerBlk nbBlk]);
% shuffle the columns/blocks
stimList=allStim(:,randperm(size(allStim,2)));
% recreate a 1D vector
stimList = reshape(stimList,[1 trialPerBlk*nbBlk]);
expInfo.trialRandomization.trialList = stimList;
expInfo.trialRandomization.blockList = sort(repmat(1:nbBlk,1,trialPerBlk));


end

