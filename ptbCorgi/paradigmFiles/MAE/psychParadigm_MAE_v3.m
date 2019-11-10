function [conditionInfo, expInfo] = psychParadigm_MAE_v3(expInfo)
% overlapping gratings 
% test at 0 or 180 deg phase 
% for 0 phase, move it by 3arcmin
% adapt at 4.72Hz test at 4.25Hz
% ask the sbj to report the direction of the motion all the time but only
% get the response at the beginning of each test cycle

% plan for 2 exp: 
% 1 + 0.5 cycle/deg overlapping + single 0.5 sMAE
% 0.25 + 0.5 cycle/deg + single 0.5 dMAE

% should still check that the adaptation ends on 0 phase
% check also how long to adapt/test (how long is the MAE for?)

% eeg processing: 5 epochs of 1.4 + 0.5 s = 9 s test: 1/85*20*6*5+(1/85*20*2)
% triggers: 101 102 = not meaningful
% only consider 111 to 133



KbName('UnifyKeyNames');

conditionInfo(1).direction = 'left';
% choose from none, left, or right adaptation
% sequence: none - L/R - none - L/R - none
% odd sbj = left then right
% even sbj = right then left


if strcmp(conditionInfo(1).direction, 'none')
    expInfo.trialRandomization.nBlockReps = 1;%3
    condition = 10;
else
    expInfo.trialRandomization.nBlockReps = 1; %10
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
list = repelem(2:3,expInfo.trialRandomization.nBlockReps);
expInfo.trialRandomization.trialList  = [repelem(1,expInfo.trialRandomization.nBlockReps) Shuffle(list)];

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
conditionInfo(1).adaptDuration = 142/(85/18); % 142/(85/18) in sec: 30
conditionInfo(1).testFreq = 85/20;
conditionInfo(1).yoffset = 0.05; % for 0 phase, move the stim by yoffset (will be multiply by ppd)
% 0.05 = 3arcmin
% have tried 0.03 in the split version expt
conditionInfo(1).f1 = 0.5; % cycle/deg
conditionInfo(1).f2 = 1;

%%%%%%%%%%%% parameters for the different conditions
conditionTemplate = conditionInfo(1); 
conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
    'phase',[0 0 180],...
    'overlap',[0 1 1],...
    'trigger',[1+condition 2+condition 3+condition]); 

end






