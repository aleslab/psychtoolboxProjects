function [conditionInfo, expInfo] = psychParadigm_longRange_Dot(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRange';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 10;

expInfo.viewingDistance = 57;
 
% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'count the number of dots';

%% General conditions
conditionInfo(1).iti = 0.5; 
conditionInfo(1).nReps = 2; %30 repeats should make it around 60min 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 8; % max time to answer
conditionInfo(1).maxDim = 6; % max number of luminance change in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 1 8]; % in deg
conditionInfo(1).stimDuration = 10; % in sec
conditionInfo(1).preStimDuration = 1; % if set at 1sec, it will automatically be 1.2 sec to fit the right nb of cycles
conditionInfo(1).stimTagFreq = 2.5; % in Hz 
conditionInfo(1).trialFun=@trial_longRange_Dot;
conditionInfo(1).movingStep = 0;
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).dotSize = [0 0 0.5 0.5];

% same parameters in all conditions
for cc=2:9
    conditionInfo(cc) = conditionInfo(1);
end

%% experimental manipulation

% first 4 are long range
for cc=1:4
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

% 5:8 are long range
for cc=5:8
    conditionInfo(cc).xloc = 0.6; 
end
conditionInfo(5).label = 'short range';
conditionInfo(5).sideStim = 'both';
conditionInfo(5).motion = 1;
conditionInfo(6).label = 'short left';
conditionInfo(6).sideStim = 'left';
conditionInfo(7).label = 'short right';
conditionInfo(7).sideStim = 'right';
conditionInfo(8).label = 'short simult';
conditionInfo(8).sideStim = 'both';        

% last condition: sweep
conditionInfo(9).label = 'sweep';
conditionInfo(9).sideStim = 'both';
conditionInfo(9).xloc = [0.6 6]; % where it starts and ends1
conditionInfo(9).motion = 1;
conditionInfo(9).movingStep = ( conditionInfo(9).xloc(2)-conditionInfo(9).xloc(1) ) / 4; % (conditionInfo(9).stimDuration * conditionInfo(9).stimTagFreq); % distance / nbTotalCycles

end

