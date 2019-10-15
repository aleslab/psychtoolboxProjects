function [conditionInfo, expInfo] = psychParadigm_MAE_split(expInfo)
% split into 6 sections with different adaptors. Gives a break to the
% participant between each section
% means that the condition section is chosen manually at the beginning of 
% each block
% tests are blocked but blocks are random: 8 repetitions of the same test
% within a block but the order of block test within a section is random
% test is now a small shift of the overlapping stimulus (0.03 ~ 2 arcmin) or an almost
% counterphase one (0.97 or 1.97 deg depending on the spatial freq

% now use spatial fq of 0.25 and 1 (instead of 0.125 and 2). Behaviour
% should be fine and possibly increases SSVEP for low spatial fq?

% 8 times 5 s tests per adaptation block (2 tests x 4)
% 20 s + 8*15s = 2.5 min per blk = 1h ++
% 12 test conditions 
% 6 adaptor conditions repeated 4 times = 24 blocks (192 trials)
% 1 test 4.7s = 0.47 removed + 20/85*10 (2.35s epoch) * 2
% would do around 72 s recording time per test condition


KbName('UnifyKeyNames');


currentCondition = 2;

% 3 columns, 1st is spatial fq, second for direction, third for trigger
% odd triggers are static tests (10 phase), even triggers are dynamic tests
% (170 phase)
allCond = [0.25 -1 101;
    1 -1 103;
    0.25 1 105;
    1 1 107;
    0.25 0 109;
    1 0 111];


conditionInfo(1).f2 = allCond(currentCondition,1); % standard fq [0.125 2]
conditionInfo(1).direction = allCond(currentCondition,2); % direction of standard: -1 = left, 1=right
expInfo.triggerInfo.startTrial = allCond(currentCondition,3);



%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAE';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'shift';
expInfo.trialRandomization.nBlockReps   = 4; % 2 if 6 conditions are tested (4 if only 3 conditions are tested)
% 
% expInfo.trialRandomization.type = 'custom';
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
conditionInfo(1).trialFun=@trial_MAE_split;
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
conditionInfo(1).longAdapt = 30; % 20 sec added to top-up for the 1st trial

%%%%%%%%%%%% parameters for the different conditions
% phase = [10 170]; 
testShift = [0.03 0.97];

conditionTemplate = conditionInfo(1); %Take the first condition as the template
conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
   'shift',testShift);



end






