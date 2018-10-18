function [conditionInfo, expInfo] = psychParadigm_LRshortDC(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'LRshortDC';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 24; % 24 blocks, 10 trials, 12 s trial = 48 min 
expInfo.trialRandomization.blockByField = 'xloc';

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
conditionInfo(1).iti = 0.5; 
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 8; % max time to answer
conditionInfo(1).maxDots = 3; % max number of dots change in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 0.5 20]; % in deg
conditionInfo(1).trialDuration = 4*6*32/85; % 4*6*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
conditionInfo(1).preStimDuration = 3*32/85; 
conditionInfo(1).trialFun=@trial_LRshortDC;
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).dotSize = [0 0 0.2 0.2];
conditionInfo(1).xloc = -0.3;
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).simult = 0;
conditionInfo(1).stimTagFreq = 85/16; % this is for half motion cycle and halfcycle conditions, full cycle condition is twice stimTagFreq
conditionInfo(1).framesOn = 4;

% same parameters in all conditions
for cc=2:10
    conditionInfo(cc) = conditionInfo(1);
end

%% experimental manipulation

% first 7 are long range
for cc=1:7
    conditionInfo(cc).xMotion = 6; % in deg
end
conditionInfo(1).label = 'long range';
conditionInfo(1).sideStim = 'both';
conditionInfo(1).motion = 1;
conditionInfo(2).label = 'left';
conditionInfo(2).sideStim = 'left';
conditionInfo(2).stimTagFreq = conditionInfo(1).stimTagFreq/2;
conditionInfo(3).label = 'long right';
conditionInfo(3).sideStim = 'right';
conditionInfo(3).stimTagFreq = conditionInfo(1).stimTagFreq/2;
conditionInfo(4).label = 'long simult';
conditionInfo(4).sideStim = 'both';
conditionInfo(4).simult = 1;
conditionInfo(4).stimTagFreq = conditionInfo(1).stimTagFreq/2;

conditionInfo(5).label = 'left halfcycle';
conditionInfo(5).sideStim = 'left';
conditionInfo(6).label = 'long right halfcycle';
conditionInfo(6).sideStim = 'right';

% then short range - the repeating conditions from long range (same left
% stim)
for cc=7:10
    conditionInfo(cc).xMotion = 0.6; 
end
conditionInfo(7).label = 'short range';
conditionInfo(7).sideStim = 'both';
conditionInfo(7).motion = 1;
% conditionInfo(8).label = 'short left';
% conditionInfo(8).sideStim = 'left';
conditionInfo(8).label = 'short right';
conditionInfo(8).sideStim = 'right';
conditionInfo(8).stimTagFreq = conditionInfo(1).stimTagFreq/2;
conditionInfo(9).label = 'short simult';
conditionInfo(9).sideStim = 'both';        
conditionInfo(9).simult = 1;
conditionInfo(9).stimTagFreq = conditionInfo(1).stimTagFreq/2;

% conditionInfo(11).label = 'short left halfcycle';
% conditionInfo(11).sideStim = 'left';
% conditionInfo(11).stimTagFreq = conditionInfo(1).stimTagFreq*2;
% conditionInfo(11).cycle = 'half';
conditionInfo(10).label = 'short right halfcycle';
conditionInfo(10).sideStim = 'right';


% % last condition: sweep
% conditionInfo(15).label = 'sweep';
% conditionInfo(15).sideStim = 'both';
% conditionInfo(15).xloc = [0.6 6]; % where it starts and ends1
% conditionInfo(15).motion = 1;
% conditionInfo(15).movingStep = ( conditionInfo(15).xloc(2)-conditionInfo(15).xloc(1) ) / 4; % (conditionInfo(9).trialDuration * conditionInfo(9).stimTagFreq); % distance / nbTotalCycles

end

