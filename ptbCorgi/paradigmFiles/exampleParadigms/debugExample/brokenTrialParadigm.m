function [conditionInfo,expInfo] = brokenTrialParadigm(expInfo)
%This is an example paradigm file that implements an orienatation
%discrimination task. 


%Define things that are set in expInfo for the whole experiment

%Paradigm Name is a short name that identifies this paradigm
expInfo.paradigmName = 'brokenTrial';

%Randomly present each condition.
expInfo.randomizationType = 'random';

%Define the viewing distance.
expInfo.viewingDistance = 57;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .5;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;


conditionInfo(1).trialFun=@brokenTrial;
