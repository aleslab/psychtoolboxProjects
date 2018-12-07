function [conditionInfo, expInfo] = psychParadigm_diffRatings(expInfo)
% similar to the DCrating exp test different conditions:
% - one single bar
% - one low contrast single bar
% - 2nd order motion

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'diffratings';
% expInfo.trialRandomization.blockByField = 'xloc'; 
% expInfo.trialRandomization.nBlockReps   = 8; 

                
expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;
expInfo.useBitsSharp = true;
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
conditionInfo(1).xloc = 5; % eccentricity of stim centre from screen centre in deg
% + up to 1 deg to get a random location
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_diffratings;



%% experimental manipulation

% single stim condition
testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];
motionType = 0; % [0 0.1 0.6];
stimType = 1; % vertical or horizontal

% same parameters in all conditions
for cc=2:length(testedFreq)*length(onTime)*length(motionType)*length(stimType)
    conditionInfo(cc) = conditionInfo(1);
end

condNb = 1;
for stim=1:length(stimType)
    for mot=1:length(motionType)
        for testFq=1:length(testedFreq)
            for tt = 1:length(onTime)
%                 for d0.6irection=1:2
%                     for order=1:2
                        conditionInfo(condNb).stim = stimType(stim);
                        conditionInfo(condNb).xMotion = motionType(mot);
                        conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
                        conditionInfo(condNb).dutyCycle =onTime(tt)/8;
%                         conditionInfo(condNb).direction = direction;
%                         conditionInfo(condNb).order = order;
                        conditionInfo(condNb).label = ['S' num2str(stim) 'm' num2str(mot) '_' num2str(round(testedFreq(testFq))) 'Hz ' num2str(round(onTime(tt)/8*100)) '%'];
                        condNb = condNb+1;
%                     end
%                 end
            end
        end
    end
end


%%% 
nbRep=10;
stimList = Shuffle(repmat(1:length(conditionInfo),1,nbRep));
nbBlk = 2; trialPerBlk = length(stimList)/nbBlk;

expInfo.trialRandomization.trialList = stimList;
expInfo.trialRandomization.blockList = sort(repmat(1:nbBlk,1,trialPerBlk));




end

