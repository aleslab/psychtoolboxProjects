function [conditionInfo, expInfo] = psychParadigm_dutyCycle(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRange';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 10; % 15 blocks, 1 rep per block, 15 s trial = 45 min without breaks

expInfo.viewingDistance = 57;
 
expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

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
conditionInfo(1).stimSize = [0 0 1 8]; % in deg
conditionInfo(1).xloc = 6;
conditionInfo(1).trialDuration = 10; % in sec
conditionInfo(1).trialFun=@trial_dutyCycle;
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).dotSize = [0 0 0.5 0.5];
conditionInfo(1).preStimDuration = 1.2; % in s

% same parameters in all conditions
for cc=2:15
    conditionInfo(cc) = conditionInfo(1);
end

%% experimental manipulation
% single stim condition
testedFreq = [2.5 5 10]; % in Hz this is the onset the single stimulus
onTime = [1 2 4 6 7];
condNb = 1;
for testFq=1:length(testedFreq)
    for tt = 1:5
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).label = [num2str(testedFreq(testFq)) 'Hz ' num2str(onTime(tt)/8*100) '% DC'];
        condNb = condNb+1;
    end
end

% motion condition

end

