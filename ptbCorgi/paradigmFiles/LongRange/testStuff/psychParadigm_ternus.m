function [conditionInfo, expInfo] = psychParadigm_ternus(expInfo)
% present multiple stim flashed at 2 locations
% bistable percept??
% figured that changing the distance between the 2 locations is affecting
% the percept the most so changed the prog to test different xMotion


KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DC_ternus';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'xloc'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 8;

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
conditionInfo(1).nbStim = 4;
conditionInfo(1).intX = 3; % space interval between all the stimuli
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 2 2]; % in deg
conditionInfo(1).xloc = -4.5; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 2; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_ternus_multipleTag;
conditionInfo(1).dutyCycle = 1;
conditionInfo(1).stimTagFreq = 85/32;
conditionInfo(1).periFreq = 85/28;
% 2.65Hz = 32 frames and 3.0357Hz = 28 frames
% get back at 7*32 = 8*28
% so total number of central cycles should be a multiple of 7
conditionInfo(1).trialDuration = 8*7*32/85;

%% experimental manipulation            prevCenter = tcenter;

condNb = 1;

% single stim condition
% testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
% onTime = [1 2 4 6 7];
onTime = [2:7];
typeStim = 2;

% same parameters in all conditions
for cc=2:typeStim*length(onTime)
    conditionInfo(cc) = conditionInfo(1);
end


for st=1:typeStim
    for dc=1:length(onTime)
            conditionInfo(condNb).motion = 1;
            conditionInfo(condNb).dutyCycle = onTime(dc)/8;
            conditionInfo(condNb).stimType = st;
            conditionInfo(condNb).label = ['S' num2str(st) '_' num2str(round(onTime(dc)/8*100)) '%'];
            condNb = condNb+1;
    end
end



end

