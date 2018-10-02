function [conditionInfo, expInfo] = psychParadigm_bestFreq(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'bestFreq';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'xloc'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 8; % 40 min

expInfo.viewingDistance = 57;

expInfo.listFreq = [85/64 85/32 85/16 85/8];

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
conditionInfo(1).stimSize = [0 0 0.5 10]; % in deg
conditionInfo(1).xloc = -0.3; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = -5.5; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_bestFreq;
conditionInfo(1).trialDuration = 4*64/85; % in sec (min 4 cycles)
% % target
% conditionInfo(1).tgtSize = [0 0 0.5 10]; % in deg
% conditionInfo(1).xtgt = conditionInfo(1).xloc; 
% conditionInfo(1).ytgt = conditionInfo(1).yloc;



%% experimental manipulation
motion = [0.6 3 6]; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
onTime = [1 2 4 6 7];

% same parameters in all conditions
for cc=2:length(motion)*length(onTime)
    conditionInfo(cc) = conditionInfo(1);
end

condNb = 1;
for mm = 1: length(motion)
    for tt = 1:length(onTime)
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).locMotion = motion(mm);
        conditionInfo(condNb).label = ['M' num2str(motion(mm)) 'DC' num2str(round(onTime(tt)/8*100))];
        condNb = condNb+1;
    end
end

end

