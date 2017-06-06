function [conditionInfo, expInfo] = psychParadigm_longRangeOccluder(expInfo)


%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'longRangeOccluder';


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
conditionInfo(1).trialFun=@trial_longRangeOccluder;
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).rectObs = [0 0 100 200];
conditionInfo(1).stimSize = [0 0 100 100];
conditionInfo(1).nFramesPerStim = 15;

conditionInfo(2) = conditionInfo(1);
conditionInfo(3) = conditionInfo(1);
conditionInfo(4) = conditionInfo(1);

conditionInfo(1).label = 'baseline';
conditionInfo(2).label = 'expected';
conditionInfo(3).label = 'unexpected';
conditionInfo(4).label = 'simult';


end

