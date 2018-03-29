function [conditionInfo, expInfo] = psychParadigm_LongRangeV2(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRange';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 17; % 15 blocks, 1 rep per block, 15 s trial = 45 min without breaks

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
conditionInfo(1).iti = 0.5; 
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
conditionInfo(1).trialDuration = 10; % in sec
conditionInfo(1).preStimDuration = 2; % if set at 1sec, it will automatically be 1.2 sec to fit the right nb of cycles
conditionInfo(1).stimTagFreq = 2.5; % in Hz this is the onset of 1st stimulus in the cycle (2 stim in one cycle = 5 Hz cycle)
conditionInfo(1).isi = 0.05; % in sec time OFF between 2 stimuli
conditionInfo(1).trialFun=@trial_LongRangeV2;
conditionInfo(1).movingStep = 0;
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).dotSize = [0 0 0.5 0.5];
conditionInfo(1).cycle = 'full';

% same parameters in all conditions
for cc=2:12
    conditionInfo(cc) = conditionInfo(1);
end

%% experimental manipulation

% first 7 are long range
for cc=1:7
    conditionInfo(cc).xloc = 6; % in deg
end
conditionInfo(1).label = 'long range';
conditionInfo(1).sideStim = 'both';
conditionInfo(1).motion = 1;
conditionInfo(2).label = 'long left';
conditionInfo(2).sideStim = 'left';
conditionInfo(3).label = 'long right';
conditionInfo(3).sideStim = 'right';
conditionInfo(4).label = 'long simult';
conditionInfo(4).sideStim = 'both';

conditionInfo(5).label = 'long left halfcycle';
conditionInfo(5).sideStim = 'left';
conditionInfo(5).cycle = 'half';
conditionInfo(6).label = 'long right halfcycle';
conditionInfo(6).sideStim = 'right';
conditionInfo(6).cycle = 'half';


% 7 are short range
for cc=7:12
    conditionInfo(cc).xloc = 0.6; 
end
conditionInfo(7).label = 'short range';
conditionInfo(7).sideStim = 'both';
conditionInfo(7).motion = 1;
conditionInfo(8).label = 'short left';
conditionInfo(8).sideStim = 'left';
conditionInfo(9).label = 'short right';
conditionInfo(9).sideStim = 'right';
conditionInfo(10).label = 'short simult';
conditionInfo(10).sideStim = 'both';        

conditionInfo(11).label = 'short left halfcycle';
conditionInfo(11).sideStim = 'left';
conditionInfo(11).cycle = 'half';
conditionInfo(12).label = 'short right halfcycle';
conditionInfo(12).sideStim = 'right';
conditionInfo(12).cycle = 'half';


% % last condition: sweep
% conditionInfo(15).label = 'sweep';
% conditionInfo(15).sideStim = 'both';
% conditionInfo(15).xloc = [0.6 6]; % where it starts and ends1
% conditionInfo(15).motion = 1;
% conditionInfo(15).movingStep = ( conditionInfo(15).xloc(2)-conditionInfo(15).xloc(1) ) / 4; % (conditionInfo(9).trialDuration * conditionInfo(9).stimTagFreq); % distance / nbTotalCycles

end

