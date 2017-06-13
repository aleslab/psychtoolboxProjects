function [conditionInfo, expInfo] = psychParadigm_LROccluderV2(expInfo)
% no need for a 'baseline' condition: it's the same as a trial with 0 test
% + each time that the stim does appear in the central position.
% for the unexpected condition a rectangle appears in the middle so there
% is something happening exactly at the expected time (but is not the
% stimulus). That doesn't look great. Might be preferable to present the
% rectangle at another point in time or change the paradigm.
% Also why is the test restricted to the central position? In fact it would
% be better if the extrem is not presented!

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
conditionInfo(1).trialFun=@trial_LROccluderV2;
conditionInfo(1).maxTest = 3; % max number of tests (stim appearing/not in the central position) in a trial
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).rectObs = [0 0 100 200];
conditionInfo(1).stimSize = [0 0 100 100];
conditionInfo(1).nFramesPerStim = 10; % at 60Hz refresh = 6 img/sec
conditionInfo(1).stimDuration = 6; % 12 sec
conditionInfo(1).totFlip = 6 * conditionInfo(1).stimDuration; %80 for 60Hz 12sec trial

conditionInfo(2) = conditionInfo(1);
conditionInfo(3) = conditionInfo(1);
conditionInfo(4) = conditionInfo(1);

conditionInfo(1).label = 'baseline'; % no test flip
conditionInfo(2).label = 'expected';
conditionInfo(3).label = 'unexpected';
conditionInfo(4).label = 'simult';


end

