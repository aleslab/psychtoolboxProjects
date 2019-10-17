function [conditionInfo, expInfo] = psychParadigm_MAE_splitv2(expInfo)
% modif using 6 sections with different adaptors. 3 adaptors are single
% freq (using standard) and 3 are overlapping freq (standard + 1 c/deg)
% do 2 blocks of the same kind one after the other

% used 90 deg shift instead of counterphase: 
% testShift = testShift/2;
% in trial program


% block order for S16: 3 4 6 1 5 2


KbName('UnifyKeyNames');

currentCondition = 2;

% % 3 columns, 1st is spatial fq, second for direction, third for trigger
% % (the number will be added to the condition number so ends up being between 120-131)
% allCond = [0.25 -1 20;
%     1 -1 22;
%     0.25 1 24;
%     1 1 26;
%     0.25 0 28;
%     1 0 30];

allCond = [0 -1 20;
    1 -1 22;
    0 1 24;
    1 1 26;
    0 0 28;
    1 0 30];

conditionInfo(1).f2 = 1; % always use 1 c/deg
conditionInfo(1).overlap = allCond(currentCondition,1); % overlap 1 or not 0
conditionInfo(1).direction = allCond(currentCondition,2); % direction of standard: -1 = left, 1=right
conditionInfo(1).triggerCond = allCond(currentCondition,3);



%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAEshift';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.nBlockReps   = 2; % 2 if 6 conditions are tested (4 if only 3 conditions are tested)
expInfo.trialRandomization.type = 'custom'; 
tt = repmat([1 2],8*2,1); % 8 top-ups * 2 successive blocks
expInfo.trialRandomization.trialList = tt(:)'; 
bb= repmat(1:4,8,1); % 4 blocks of 8 top-ups
expInfo.trialRandomization.blockList = bb(:)'; 
% ss = Shuffle([1 3]);
% ss = [ss(1) ss(1)+1 5 6 ss(2) ss(2)+1];
% allCond = repmat(ss,32,1);allCond = allCond(:);
% expInfo.trialRandomization.trialList = allCond';
% tt= repmat(1:24,8,1);
% expInfo.trialRandomization.blockList = tt(:)'; 

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
conditionInfo(1).testDuration = 21; % in cycles. 5 seconds = 20/85*20 cycles (exactly 4.7 seconds)
% add one cycle because real refresh is 0.01176 not 0.0118 so I miss some
% data at the end of the trial...
conditionInfo(1).adaptDuration = 10; % in sec: 10s top-up
conditionInfo(1).longAdapt = 20; % 20 sec added to top-up for the 1st trial

%%%%%%%%%%%% parameters for the different conditions
% phase = [10 170]; 
testShift = [0.03 0.97];

conditionTemplate = conditionInfo(1); %Take the first condition as the template
conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
   'shift',testShift);



end






