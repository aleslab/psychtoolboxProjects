function [conditionInfo, expInfo] = psychParadigm_longRange(expInfo)


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRange';
expInfo.randomizationType = 'random';
expInfo.viewingDistance = 57;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'press any key to go to the next trial ';

%% General conditions
conditionInfo(1).iti = 0.5;
conditionInfo(1).nReps = 2;
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 100 100];
conditionInfo(1).nFramesPerStim = 10;
conditionInfo(1).trialFun=@trial_longRange;

% same parameters in all conditions
conditionInfo(2) = conditionInfo(1);
conditionInfo(3) = conditionInfo(1);
conditionInfo(4) = conditionInfo(1);
conditionInfo(5) = conditionInfo(1);

%% experimental manipulation
conditionInfo(1).label = 'long range';
conditionInfo(1).sideStim = 'both';
conditionInfo(1).xloc = 2; % division where the stim will be presented horizontally = centerx/2
conditionInfo(1).motion = 1;

conditionInfo(2).label = 'short range';
conditionInfo(2).sideStim = 'both';
conditionInfo(2).xloc = 6; % = centerx/6
conditionInfo(2).motion = 1;

conditionInfo(3).label = 'single left';
conditionInfo(3).sideStim = 'left';
conditionInfo(3).xloc = 2;
conditionInfo(3).motion = 0;

conditionInfo(4).label = 'single right';
conditionInfo(4).sideStim = 'right';
conditionInfo(4).xloc = 2;
conditionInfo(4).motion = 0;

conditionInfo(5).label = 'long simult';
conditionInfo(5).sideStim = 'both';
conditionInfo(5).xloc = 2;
conditionInfo(5).motion = 0;

% expInfo.center does NOT exist (at the beginning) so the following won't work
% conditionInfo(1).ycoord = expInfo.center(2)/2; 
% conditionInfo(1).xcoord = 2*expInfo.center(1)/3; % distance define from centre
% conditionInfo(2).xcoord = expInfo.center(1)/4; % will be above (- in the trial function)

end

