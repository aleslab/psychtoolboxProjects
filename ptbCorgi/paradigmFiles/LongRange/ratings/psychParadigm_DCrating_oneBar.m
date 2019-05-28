function [conditionInfo, expInfo] = psychParadigm_DCrating_oneBar(expInfo)
% One Bar stim tested on 4 freq and 7 DC

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DCrating_oneBar';
expInfo.trialRandomization.blockByField = 'xloc';
expInfo.trialRandomization.nBlockReps   = 8;


expInfo.viewingDistance = 57;

expInfo.enableTriggers = false;
expInfo.useBitsSharp = true;
expInfo.trialRandomization.type = 'blocked';


%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;
expInfo.fixationInfo(1).loc = [-5 0]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

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
conditionInfo(1).xloc = 8; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_DCrating_oneBar;
conditionInfo(1).trialDuration = 5*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
conditionInfo(1).motion = 0; % by default, no motion
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
% conditionInfo(1).loc1 = 2; % xlocation of the 2nd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).loc2 = 4; % x coord of the 3rd stimulus IN ADDITION to the first stimulus
% conditionInfo(1).horizBar = [0 0 conditionInfo(1).loc2+0.5 0.1];
% conditionInfo(1).lineSize = 0.3;
conditionInfo(1).stimSize = [0 0 0.5 10]; % in deg
conditionInfo(1).texRect = [0 0 6 12]; % texture rect for gaussian

%% experimental manipulation

condNb = 1;

% single stim condition
testedFreq = [85/32 85/16 85/8]; % in Hz this is the onset of the single stimulus
onTime = 1:7;


% same parameters in all conditions
for cc=1:(length(testedFreq)*length(onTime)) * 2 + 7*2 % multiply 2 for moving or not
    conditionInfo(cc) = conditionInfo(1);
end

for mot=0:1
    for testFq=1:length(testedFreq)
        for tt = 1:length(onTime)
            conditionInfo(condNb).motion = mot;
            conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
            conditionInfo(condNb).dutyCycle = onTime(tt)/8;
            conditionInfo(condNb).label = ['m' num2str(mot) '_' num2str(round(testedFreq(testFq))) 'Hz ' num2str(round(onTime(tt)/8*100)) '%'];
            condNb = condNb+1;
        end
    end
end

% add 7hz (different DC)
testedFreq = 85/12;
onTime = [2 3 4 6 8 9 10];

for mot=0:1
    for testFq=1:length(testedFreq)
        for tt = 1:length(onTime)
            conditionInfo(condNb).motion = mot;
            conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
            conditionInfo(condNb).dutyCycle = onTime(tt)/12;
            conditionInfo(condNb).label = ['m' num2str(mot) '_' num2str(round(testedFreq(testFq))) 'Hz ' num2str(round(onTime(tt)/12*100)) '%'];
            condNb = condNb+1;
        end
    end
end

end

