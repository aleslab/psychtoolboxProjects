function [conditionInfo, expInfo] = psychParadigm_MAE_splitLong(expInfo)
% use longer adaptation period: 15 s adaptation, 5 s test (+ 30 s at the
% beginning of the block)

% shift: 0.05 and 0.95
% used 90 deg shift instead of counterphase: 
% testShift = testShift/2;
% in trial program



KbName('UnifyKeyNames');

currentCondition = 2;


switch currentCondition
    case 1
        % condition 1
        condGrating = 1;
        conditionInfo(1).overlap = 1;
        test = 2;
        conditionInfo(1).direction = -1;
        conditionInfo(1).triggerCond = 20;
    case 2
        condGrating = 2;
        test = 1;
        conditionInfo(1).triggerCond = 22;
        dirAdapt = -1;
    case 3
        condGrating = 1;
        conditionInfo(1).overlap = 0;
        test = 1;
        conditionInfo(1).direction = 0;
        conditionInfo(1).triggerCond = 27;
    case 4
        condGrating = 1;
        conditionInfo(1).overlap = 1;
        test = 2;
        conditionInfo(1).direction = 1;
        conditionInfo(1).triggerCond = 24;
    case 5
        condGrating = 2;
        dirAdapt = 1;
        test = 1;
        conditionInfo(1).triggerCond = 26;
end



conditionInfo(1).f2 = 1; % always use 1 c/deg

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAEsplitLong';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.nBlockReps   = 2; % 2 if 6 conditions are tested (4 if only 3 conditions are tested)
expInfo.trialRandomization.type = 'custom'; 
if currentCondition == 3
    expInfo.trialRandomization.trialList = ones(1,16);
    bb= repmat(1:2,8,1);
    expInfo.trialRandomization.blockList = bb(:)';   
else 
    tt = repmat([1 2],8*2,1); % 8 top-ups * 2 successive blocks
    expInfo.trialRandomization.trialList = tt(:)';
    bb= repmat(1:4,8,1); % 4 blocks of 8 top-ups
    expInfo.trialRandomization.blockList = bb(:)';
end

expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;
% expInfo.useBitsSharp = false; 
% expInfo.enableTriggers = false;

expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .4;
expInfo.fixationInfo(1).lineWidthPix = 3;
expInfo.fixationInfo(1).color = 0;
expInfo.fixationInfo(1).loc = [0 0]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)
% expInfo.fixationInfo(1).type = 'noiseFrame';
% expInfo.fixationInfo(1).size = 4;

expInfo.instructions = 'FIXATE the cross';

conditionInfo(1).maxToAnswer = 2;
conditionInfo(1).iti = 0;
conditionInfo(1).nReps = 8; % 8 top-up test
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAE_splitv2;
conditionInfo(1).stimSize = 24; % grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).yEccentricity = 7;
conditionInfo(1).f1 = 0.5; % in cycle (changes to c/deg in the trial pg)
conditionInfo(1).tempFq = 85/16 ; % 85/18 or 85/16? 4.72 Hz or 5.3125
conditionInfo(1).testFreq = 85/20; % 4.25 Hz
conditionInfo(1).testDuration = 5; % in cycles. 5 seconds = 20/85*20 cycles (exactly 4.7 seconds)
% add one cycle because real refresh is 0.01176 not 0.0118 so I miss some
% data at the end of the trial...
conditionInfo(1).adaptDuration = 5; % in sec: 15s top-up
conditionInfo(1).longAdapt = 2; % 30 sec added to top-up for the 1st trial

%%%%%%%%%%%% parameters for the different conditions
% phase = [10 170]; 
% testShift = [0.03 0.97];

% conditionTemplate = conditionInfo(1); %Take the first condition as the template
% conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
%    'shift',testShift);
conditionInfo(1).shift = 0.95;

if test == 2
    conditionInfo(2) = conditionInfo(1);
    conditionInfo(2).shift = 0.05;
end
if condGrating == 2
    conditionInfo(2) = conditionInfo(1);
    conditionInfo(1).overlap = 1;
    conditionInfo(1).direction = 0;
    conditionInfo(2).overlap = 0;
    conditionInfo(2).direction = dirAdapt;    
end

end






