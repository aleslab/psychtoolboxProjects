function [conditionInfo, expInfo] = psychParadigm_ss_image_swap(expInfo)

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'example_image_swap';


expInfo.instructions = 'Instructions can go here. ';


%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@trial_ss_image_swap;
conditionInfo(1).nReps = 2; %number of repeats

conditionInfo(1).iti  = 0;
conditionInfo(1).type = 'generic';
conditionInfo(1).nPrePost = 1; % amount of cycles to prefix and postfix, 1 cycle is an AB alternation
conditionInfo(1).nFramesPerStim = 3; %This will set the alternation rate.
conditionInfo(1).nPairRepeats = 10; % Number of times to repeat a pair.
conditionInfo(1).responseDuration = 1;    %Post trial window for waiting for a response

%conditionInfo(1).nStim = 1;  %Obsolete
conditionInfo(1).nPairs = 3;


%Image matrix is xPixels x yPixels x Number of Pairs x 2 (two images per
%pair
% Insert code to load images here.  Probably best as a function
% We might run into some difficulty with image sizes if we're not careful
% so try to keep them as small as possible.
conditionInfo(1).imageMatrix(:,:,1,1) = .5*ones(100,100);
conditionInfo(1).imageMatrix(:,:,1,2) = zeros(100,100);
conditionInfo(1).imageMatrix(:,:,2,1) = .5*ones(100,100);
conditionInfo(1).imageMatrix(:,:,2,2) =  ones(100,100);
conditionInfo(1).imageMatrix(:,:,3,1) = .5*ones(100,100);
conditionInfo(1).imageMatrix(:,:,3,2) = zeros(100,100);






