function [conditionInfo, expInfo] = psychParadigm_MoveLine_2afc(expInfo)

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'example_image_swap';


expInfo.instructions = 'Instructions can go here. ';


%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@trial_ss_image_swap;
conditionInfo(1).nReps = 5; %number of repeats
conditionInfo(1).type             = 'generic'; 
conditionInfo(1).nPrePost = 1; % amount of cycles to prefix and postfix 
conditionInfo(1).nFramesPerStim = 10;
conditionInfo(1).responseDuration = 1;    %Post trial window for waiting for a response

conditionInfo(1).nStim = 2;
conditionInfo(1).imageMatrix(:,:,1) = ones(100,100);
conditionInfo(1).imageMatrix(:,:,2) = zeros(100,100);






