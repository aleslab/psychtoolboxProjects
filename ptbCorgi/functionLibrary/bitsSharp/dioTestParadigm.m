function [conditionInfo, expInfo] = dioTestParadigm(expInfo)
% no need for a 'baseline' condition: it's the same as a trial with 0 test
% + each time that the stim does appear in the central position.
% for the expected condition a rectangle appears in the middle so there
% is something happening exactly at the expected time (but is not the
% stimulus). Instead, present occluder at the beginning of a sequence 
% (1st of the 12 possible locations of the stim)


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DIOtest';

expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;

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
conditionInfo(1).F1 = 85/85;
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).trialFun=@dioTestTrial
conditionInfo(1).label = '85/20';
conditionInfo(2) = conditionInfo(1);
conditionInfo(2).F1 = 86/43;
conditionInfo(2).label = '85/40';
