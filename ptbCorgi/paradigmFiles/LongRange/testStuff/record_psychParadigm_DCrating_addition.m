function [conditionInfo, expInfo] = psychParadigm_DCrating_addition(expInfo)
% similar to the DCrating exp test different conditions:
% - one single bar
% - one low contrast single bar
% - 2nd order motion

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'testRec';
% expInfo.trialRandomization.blockByField = 'xloc'; 
% expInfo.trialRandomization.nBlockReps   = 8; 

                
expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;
expInfo.useBitsSharp = true;
expInfo.trialRandomization.type = 'custom';

%%% this is for fully random trials
% expInfo.trialRandomization.trialList = Shuffle(repmat(1:90,1,6));% 90 trials repeated 6 times
% expInfo.trialRandomization.blockList = sort(repmat(1:12,1,length(expInfo.trialRandomization.trialList)/12)); % split into 12 blocks

%%% this is with different stim in separate blocks
% gonna have 5 blocks per stim, each of 36 trials
% 90 conditions repeated 6 times
nbBlk = 15; nbTrials = 36;
allStim = [];
for btype = 1:3
    allStim = [allStim Shuffle(repmat(1+30*(btype-1):30*btype,1,6))];
end
allStim=reshape(allStim,[nbTrials nbBlk]);
% shuffle the columns/blocks
stimList=allStim(:,randperm(size(allStim,2)));
% recreate a 1D vector
stimList = reshape(stimList,[1 nbTrials*nbBlk]);
expInfo.trialRandomization.trialList = stimList;
expInfo.trialRandomization.blockList = sort(repmat(1:nbBlk,1,nbTrials));


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
conditionInfo(1).stimSize = [0 0 0.5 10]; % in deg
conditionInfo(1).xloc = 5; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@record_trial_DCrating_addition;
conditionInfo(1).trialDuration = 6*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
% conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
% conditionInfo(1).loc1 = 2; % xlocation of the 2nd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).loc2 = 4; % x coord of the 3rd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).horizBar = [0 0 conditionInfo(1).loc2+0.5 0.1];
% conditionInfo(1).lineSize = 0.3;

conditionInfo(1).texRect = [0 0 6 12];

%% experimental manipulation

condNb = 1;

% single stim condition
testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];

% same parameters in all conditions
for cc=2:length(testedFreq)*length(onTime)*2*3
    conditionInfo(cc) = conditionInfo(1);
end


for stim=1:3
    for mot=0:1
        for testFq=1:length(testedFreq)
            for tt = 1:length(onTime)
                conditionInfo(condNb).motion = mot;
                conditionInfo(condNb).stim = stim;
                conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
                conditionInfo(condNb).dutyCycle = onTime(tt)/8;
                conditionInfo(condNb).label = ['S' num2str(stim) 'm' num2str(mot) '_' num2str(round(testedFreq(testFq))) 'Hz ' num2str(round(onTime(tt)/8*100)) '%'];
                condNb = condNb+1;
            end
        end
    end
end


end

