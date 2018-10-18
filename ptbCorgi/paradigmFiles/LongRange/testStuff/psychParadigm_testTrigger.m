function [conditionInfo, expInfo] = psychParadigm_testTrigger(expInfo)
% fix iti? why not 500+500*rand(1)

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'testTrigger';
expInfo.randomizationType = 'random';
expInfo.viewingDistance = 57;
 
expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;
% expInfo.useBitsSharp = false; 
% expInfo.enableTriggers = false;

conditionInfo(1).trialFun=@testTrigger;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

end