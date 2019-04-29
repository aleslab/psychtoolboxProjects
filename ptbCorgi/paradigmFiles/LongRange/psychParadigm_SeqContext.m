function [conditionInfo, expInfo] = psychParadigm_SeqContext(expInfo)
% change from V1: left position is not kept the same across short and long
% range = 12 possible conditions

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'SeqContext';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nBlockReps   = 18; 

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
expInfo.fixationInfo(1).loc = [0 -8]; % location of the fixation relative to centre in degrees (1st number is horizontal, 2nd is vertical)

expInfo.instructions = 'FIXATE the dot and count the number of dots appearing on the bar';

%% General conditions
conditionInfo(1).iti = 0.5; % inter-trial-interval
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 999; % next trial starts only after giving an answer % max time to answer
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 0.75 15]; % in deg
conditionInfo(1).dotSize = [0 0 0.5 0.5];
conditionInfo(1).yloc = 2; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_SeqContext;
conditionInfo(1).nbSeq = 2;
conditionInfo(1).trialDuration = conditionInfo(1).nbSeq*10*16/85; % in sec (multiply by the nb of stimuli, 10x2directions, and nb of repeats)
conditionInfo(1).stimTagFreq = 85/24;
conditionInfo(1).dutyCycle = 4/8;
% testedFreq = [85/8 85/16 85/32];

% same parameters in all conditions
for cc=2:8
    conditionInfo(cc) = conditionInfo(1);
end
for cc=1:4
    conditionInfo(cc).xloc = [-9 -3 3 9]; % eccentricity of stim centre from screen centre in deg
end
for cc=5:8
    conditionInfo(cc).xloc = [-1.5 -0.5 0.5 1.5]; % eccentricity of stim centre from screen centre in deg
end

conditionInfo(1).seq = [1 2 3 4 5 4 3 2 1 5]; % 5 is for a OFF screen
conditionInfo(1).label = 'motionLR';
conditionInfo(2).seq = [1 3 2 4 5 4 2 3 1 5];
conditionInfo(2).label = 'predictableLR';
conditionInfo(3).seq = 0;
conditionInfo(3).label = 'randomLR'; % keep temporality
conditionInfo(4).seq = 6;
conditionInfo(4).label = 'fullrandomLR';

conditionInfo(5).seq = [1 2 3 4 5 4 3 2 1 5]; % 5 is for a OFF screen
conditionInfo(5).label = 'motionSR';
conditionInfo(6).seq = [1 3 2 4 5 4 2 3 1 5];
conditionInfo(6).label = 'predictableSR';
conditionInfo(7).seq = 0;
conditionInfo(7).label = 'randomSR'; % keep temporality
conditionInfo(8).seq = 6;
conditionInfo(8).label = 'fullrandomSR';

end


