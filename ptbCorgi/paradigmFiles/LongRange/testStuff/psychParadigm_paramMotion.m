function [conditionInfo, expInfo] = psychParadigm_paramMotion(expInfo)
% paradigm with 2 rows of objects, flashing one after the other top/bottom
% then left to right

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DC_rating_multiple';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'trialDuration'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 8; % 40 min

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
conditionInfo(1).stimSize = [0 0 1 3]; % in deg
conditionInfo(1).yloc = [6 -6]; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_paramMotion;
conditionInfo(1).trialDuration = 24*64/85; % in sec (min 4 cycles)
conditionInfo(1).nbRepeat = 24; % number of entire motion stream repeat
% % target
% conditionInfo(1).tgtSize = [0 0 0.5 10]; % in deg
% conditionInfo(1).xtgt = conditionInfo(1).xloc; 
% conditionInfo(1).ytgt = conditionInfo(1).yloc;



%% experimental manipulation
testedFreq = [85/64 85/32 85/16 85/8]; % in Hz this is the onset of the single stimulus
onTime = 1:8;
steps = [1 4];

% same parameters in all conditions
for cc=2:length(testedFreq)*length(onTime)*length(steps)
    conditionInfo(cc) = conditionInfo(1);
end


condNb = 1;
for rr=1:length(steps)
for testFq=1:length(testedFreq)
    for tt = 1:length(onTime)
        conditionInfo(condNb).xloc = -7.5:steps(rr):7.5 ; % short or long range
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).label = ['range' num2str(rr) 'fq' num2str(round(testedFreq(testFq))) 'dc' num2str(round(onTime(tt)/8*100))];
        condNb = condNb+1;
    end
end
end

end

