function [conditionInfo, expInfo] = psychParadigm_DCrating_size(expInfo)
% similar to the DCrating exp test the effect of the size of the stim +
% what if it is a gaussian

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DCrating_size';
expInfo.trialRandomization.blockByField = 'xloc';
expInfo.trialRandomization.nBlockReps   = 8;


expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = false;
expInfo.enableTriggers = false;
expInfo.useBitsSharp = true;
expInfo.trialRandomization.type = 'blocked';

% %%% this is for fully random trials
% expInfo.trialRandomization.trialList = Shuffle(repmat(1:40,1,6));% 90 trials repeated 6 times
% expInfo.trialRandomization.blockList = sort(repmat(1:12,1,length(expInfo.trialRandomization.trialList)/12)); % split into 12 blocks

% %%% this is with different stim in separate blocks
% % gonna have 5 blocks per stim, each of 36 trials
% % 90 conditions repeated 6 times
% nbBlk = 15; nbTrials = 36;
% allStim = [];
% for btype = 1:3
%     allStim = [allStim Shuffle(repmat(1+30*(btype-1):30*btype,1,6))];
% end
% allStim=reshape(allStim,[nbTrials nbBlk]);
% % shuffle the columns/blocks
% stimList=allStim(:,randperm(size(allStim,2)));
% % recreate a 1D vector
% stimList = reshape(stimList,[1 nbTrials*nbBlk]);
% expInfo.trialRandomization.trialList = stimList;
% expInfo.trialRandomization.blockList = sort(repmat(1:nbBlk,1,nbTrials));


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
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimType = 1; % normal stim (2 = gaussian)
conditionInfo(1).xloc = 5; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 3; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_DCrating_size;
conditionInfo(1).trialDuration = 6*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
conditionInfo(1).motion = 0; % by default, no motion
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
% conditionInfo(1).loc1 = 2; % xlocation of the 2nd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).loc2 = 4; % x coord of the 3rd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).horizBar = [0 0 conditionInfo(1).loc2+0.5 0.1];
% conditionInfo(1).lineSize = 0.3;

conditionInfo(1).texRect = [0 0 6 12]; % texture rect for gaussian

%% experimental manipulation

condNb = 1;

% single stim condition
testedFreq = [85/32]; % in Hz this is the onset of the single stimulus
% onTime = [1 2 4 6 7];
onTime = [1 7];

% get all the different possible sizes of the stimuli
stimSize = [0 0 2 2];
dd=0;
for ratio = 1:2:10
    dd=dd+1;
    curSize(dd,:) = [0 0 stimSize(3)/ratio stimSize(4)*ratio];
end
for ratio = [1 9]
    dd=length(curSize);
    curSize(dd+1,:) = [0 0 stimSize(3)*ratio 0.4];
    curSize(dd+2,:) =  [0 0 0.4 stimSize(4)*ratio];
end

% same parameters in all conditions
for cc=1:(length(testedFreq)*length(onTime)*length(curSize) + 2) * 2 % add the 2 gaussian conditions and multiply 2 for moving or not
    conditionInfo(cc) = conditionInfo(1);
end

for mot=1:2
    for testFq=1:length(testedFreq)
        for tt = 1:length(onTime)
            for taille=1:length(curSize)
                conditionInfo(condNb).motion = mot-1;
                conditionInfo(condNb).stimSize = curSize(taille,:);
                conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
                conditionInfo(condNb).dutyCycle = onTime(tt)/8;
                conditionInfo(condNb).label = ['S1' num2str(mot) 'Size' num2str(curSize(taille,3),'%.1f') '-' num2str(curSize(taille,4),'%.1f') '-' num2str(round(onTime(tt)/8*100)) '%'];
                condNb = condNb+1;
            end
        end
    end
end

% add a couple of conditions for gaussian stim
% change DC
for mot=1:2
    for testFq=1:length(testedFreq)
    for tt = 1:length(onTime)
        conditionInfo(condNb).stimSize = [0 0 0.4 10]; % does not matter but requiered for horizontal check
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
        conditionInfo(condNb).motion = mot-1;
        conditionInfo(condNb).stimType = 2;
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).label = ['S2' num2str(mot) 'Size' num2str(curSize(taille,3),'%.1f') '-' num2str(curSize(taille,4),'%.1f') '-' num2str(round(onTime(tt)/8*100)) '%'];
        condNb = condNb+1;
    end
    end
end

end

