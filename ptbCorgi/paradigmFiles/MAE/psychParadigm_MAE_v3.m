function [conditionInfo, expInfo] = psychParadigm_MAE_v3(expInfo)
% overlapping gratings 
% adapt at 4.72Hz test at 8.5Hz
% reason for 8.5 is that the motion direction effect is at around 80-100 ms
% after stim onset which should be around 8-12Hz (otherwise the adaptated
% response is spread to other odd harmonics = smaller response in each
% harmonic). The effect being around 80-100 ms is probably due to the
% adaptation speed of the stimulus
% also chose to present the stimulus in the fovea because the SSVEP adapted
% response is much higher than if the fovea is not included
% ask the sbj to report the direction of the motion all the time but only
% get the response at the beginning of each test cycle
% the overlapping gratings look different for left and right adaptation 
% (mirrored). The left and no adaptation conditions are the same.

% for moving the test stimulus, do I move by phase or by distance? 
% if phase then not the same distance for both stimuli and the stimulus
% will look different between the 2 frames
% if distance the stimulus looks the same but the phase is not equal for
% the 2 stimuli so the velocity/amount of left-right motion in the test is 
% different for the 2 stimuli. Major problem is that if say 0.5 stim is at
% 90 deg phase then the 1 cycle stim is at counterphase and the 0.25 at 40
% deg phase. So a difference in the adapted response could be due to a
% difference in the amount of phase change. 
% Finally decide to move by a phase of 10 and 90 deg. 10 deg is around
% 3arcmin for 0.5 cycle/deg stim (9deg is 3 arcmin). The test is moving to the right at the
% second frame for both stimuli (e.g. whatever the adapted direction) but
% while keeping the stimulus the way it should look (ie flipped/mirror)

% plan for 2 exp: 
% 1 + 0.5 cycle/deg overlapping + single 0.5 sMAE
% 0.25 + 0.5 cycle/deg + single 0.5 dMAE

% 30 s adaptation
% eeg processing: 6 epochs of 1.4 + 0.5 s = 9 s test: 1/85*20*6*6+(1/85*20*2)
% triggers: 101 102 = not meaningful
% only consider 111 to 133

% what about comparison with both adaptation (adaptation left + right alternating as a control condition)
% and the role of attention?


KbName('UnifyKeyNames');

conditionInfo(1).direction = 'none';
% choose from none, left, or right adaptation
% sequence: none - L/R - none - L/R - none
% odd sbj = left then right
% even sbj = right then left


if strcmp(conditionInfo(1).direction, 'none')
    expInfo.trialRandomization.nBlockReps = 3;%3
    condition = 10;
else
    expInfo.trialRandomization.nBlockReps = 9; %9
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

expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;

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
conditionInfo(1).stimSize = 32; % 32 grating image in degrees. 
% should be an integer of 8 so that the lowest spatial frequency grating will
% have full cycles only = the average luminance of the grating is equal to the background luminance 
conditionInfo(1).tempFq = 85/18; % 85/18 or 85/16? 4.72 Hz 
conditionInfo(1).testDuration = (20*6*6 + 20*2)/85; % in s (20*6*5 + 20*2)/85 = 9 s
conditionInfo(1).adaptDuration = 142/(85/18); % 142/(85/18) in sec: 30
conditionInfo(1).testFreq = 85/10;
conditionInfo(1).yoffset = 0.05; % for 0 phase, move the stim by yoffset (will be multiply by ppd)
% 0.05 = 3arcmin
% have tried 0.03 in the split version expt
conditionInfo(1).f1 = 0.5; % cycle/deg
conditionInfo(1).f2 = 1; % 1 or 0.25

%%%%%%%%%%%% parameters for the different conditions
conditionTemplate = conditionInfo(1); 
conditionInfo = createConditionsFromParamList(conditionTemplate,'pairwise',...
    'phase',[10 10 90],...
    'overlap',[0 1 1],...
    'trigger',[1+condition 2+condition 3+condition]); 

end






