function [conditionInfo, expInfo] = psychParadigm_LROccluderV3(expInfo)
% no need for a 'baseline' condition: it's the same as a trial with 0 test
% + each time that the stim does appear in the central position.
% for the expected condition a rectangle appears in the middle so there
% is something happening exactly at the expected time (but is not the
% stimulus). Instead, present occluder at the beginning of a sequence 
% (1st of the 12 possible locations of the stim)


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRangeOccluder';
expInfo.occluder = 1; % present occluders or not

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
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 2; % max time to answer
conditionInfo(1).trialFun=@trial_LROccluderV3;
conditionInfo(1).maxTest = 3; % max number of tests (stim appearing/not in the central position) in a trial
conditionInfo(1).maxDim = 5; % max number of luminance change in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).rectObs = [0 0 2 2];
conditionInfo(1).stimSize = [0 0 2 2];
conditionInfo(1).nFramesPerStim = 15; % at 75Hz refresh = 5 img/sec
conditionInfo(1).stimDuration = 6; % 12 sec
conditionInfo(1).totFlip = (75/conditionInfo(1).nFramesPerStim) * conditionInfo(1).stimDuration; %80 for 60Hz 12sec trial

conditionInfo(2) = conditionInfo(1);
conditionInfo(3) = conditionInfo(1);
conditionInfo(4) = conditionInfo(1);

conditionInfo(1).label = 'baseline'; % no test flip
conditionInfo(2).label = 'expected';
conditionInfo(3).label = 'unexpected';
conditionInfo(4).label = 'simult';


end

