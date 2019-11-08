function [conditionInfo, expInfo] = psychParadigm_MAE_v3(expInfo)
% overlapping gratings of 1 and 0.25 cycle/deg
% test at 10 or 180 deg phase
% adapt at 4.72Hz test at 4.25Hz
% add one condition with only one grating for comparison purposes

% 30s adapt followed by 9.4 s test (1st s not used)
% eeg processing: 5 epochs of 1.4 + 1 s = 8 s test: 1/85*20*6*6+(1/85*20*4)
% triggers: 101 102 = not meaningful
% only consider 111 to 133
% ask the sbj to report the direction of the motion all the time but only
% get the response at the beginning of each test cycle


KbName('UnifyKeyNames');

conditionInfo(1).direction = 'left';
% choose from none, left, or right adaptation
% sequence: none - L/R - none - L/R - none
% odd sbj = left then right
% even sbj = right then left


if strcmp(conditionInfo(1).direction, 'none')
    expInfo.trialRandomization.nBlockReps = 3;
    condition = 10;
else
    expInfo.trialRandomization.nBlockReps = 9; 
    if strcmp(conditionInfo(1).direction, 'left')
        condition = 20;
    elseif strcmp(conditionInfo(1).direction, 'right')
        condition = 30;
    end
end


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'MAEv3';
expInfo.viewingDistance = 57;
expInfo.trialRandomization.type = 'custom';
expInfo.giveAudioFeedback = 0;
list = repelem(1:3,expInfo.trialRandomization.nBlockReps);
% expInfo.trialRandomization.trialList  = list;
expInfo.trialRandomization.trialList  = Shuffle(list);

% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;

expInfo.fixationInfo(1).type  = 'dot';
expInfo.fixationInfo(1).size  = .15; % radius of the dot
expInfo.fixationInfo(1).loc = [0 0]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE the dot';
expInfo.showTrialNb = 1; % give trial nb at the end of each trial (+ wait for keyboard)

conditionInfo(1).iti = 0;
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@trial_MAEv3;
conditionInfo(1).stimSize = 24; % 24 grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).tempFq = 85/18; % 85/18 or 85/16? 4.72 Hz 
conditionInfo(1).testDuration = (20*6*6 + 20*4)/85; % in s (20*6*5 + 20*4)/85 = 9.4 s
conditionInfo(1).adaptDuration = 30; % in sec: 30
conditionInfo(1).f1 = 1; % cycle/deg
conditionInfo(1).f2 = 0.25; % cycle/deg
conditionInfo(1).testFreq = 85/20;

%%%%%%%%%%%% parameters for the different conditions
conditionTemplate = conditionInfo(1); 
conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
    'phase',[180 10 180],...
    'overlap',[0 1 1],...
    'trigger',[1+condition 2+condition 3+condition]); 

end






