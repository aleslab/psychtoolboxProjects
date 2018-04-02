function [conditionInfo, expInfo] = psychParadigm_dutyCycle(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'dutyCycle';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'xloc'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 10; 
% 10 repetitions * 14 s per trial (including resp) * 22 conditions = 50 min

expInfo.viewingDistance = 57;
 
expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;
% expInfo.useBitsSharp = false; 
% expInfo.enableTriggers = false;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'FIXATE the cross and count the number of dots appearing on the bar';

%% General conditions
conditionInfo(1).iti = 0.5; % inter-trial-interval
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 8; % max time to answer
conditionInfo(1).maxDots = 3; % max number of luminance change in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 0.5 10]; % in deg
conditionInfo(1).xloc = 3; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 5; % y eccentricity of stim centre
conditionInfo(1).trialDuration = 10; % in sec
conditionInfo(1).trialFun=@trial_dutyCycle;
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).dotSize = [0 0 0.2 0.2];
conditionInfo(1).preStimDuration = 1.2; % in s
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)

% same parameters in all conditions
for cc=2:22
    conditionInfo(cc) = conditionInfo(1);
end

%% experimental manipulation
% single stim condition

% testedFreq = [2.5 5 10]; % in Hz this is the onset of the single stimulus
% cycle = [0.2 0.5 1 2 5];
% onTime = 1:5;
% condNb = 1;
% for testFq=1:length(testedFreq)
%     for cc = 1:length(cycle)
%         conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
%         conditionInfo(condNb).dutyCycle = onTime(cc);
%         conditionInfo(condNb).label = [num2str(testedFreq(testFq)) 'Hz ' num2str(cycle(cc)/6*100) '% DC'];
%         condNb = condNb+1;
%     end
% end


testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];
condNb = 1;
for testFq=1:length(testedFreq)
    for tt = 1:length(onTime)
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).label = [num2str(testedFreq(testFq)) 'Hz ' num2str(onTime(tt)/8*100) '% DC'];
        condNb = condNb+1;
    end
end

% motion condition
% 'pyramid'
% testedFreq = [2.5 5 10 5 2.5]; % in Hz this is the onset the single stimulus
% onTime = 1:5;
% for tt = 1:length(testedFreq)
%     conditionInfo(condNb).stimTagFreq = testedFreq(tt);
%     conditionInfo(condNb).dutyCycle = onTime(tt);
%     conditionInfo(condNb).motion = 1;
%     conditionInfo(condNb).label = ['motion ' num2str(testedFreq(tt)) 'Hz ' num2str(cycle(tt)/6*100) '% DC'];
%     condNb = condNb+1;
% end

testedFreq = [85/32 85/16 85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];
for tt = 1:length(testedFreq)
    conditionInfo(condNb).stimTagFreq = testedFreq(tt);
    conditionInfo(condNb).dutyCycle = onTime(tt)/8;
    conditionInfo(condNb).motion = 1;
    conditionInfo(condNb).label = ['motion ' num2str(testedFreq(tt)) 'Hz ' num2str(onTime(tt)/8*100) '% DC'];
    condNb = condNb+1;
end

% other 50/50
conditionInfo(condNb).stimTagFreq = 85/32;
conditionInfo(condNb).dutyCycle = 4/8;
conditionInfo(condNb).motion = 1;
conditionInfo(condNb).label = ['motion ' num2str(85/32) 'Hz 50% DC'];

conditionInfo(condNb+1).stimTagFreq = 85/16;
conditionInfo(condNb+1).dutyCycle = 4/8;
conditionInfo(condNb+1).motion = 1;
conditionInfo(condNb+1).label = ['motion ' num2str(85/16) 'Hz 50% DC'];
end

