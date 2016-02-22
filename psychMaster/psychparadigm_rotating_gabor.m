function [conditionInfo,expInfo] = psychparadigm_rotating_gabor(expInfo)
expInfo.paradigmName = 'noiseDetect';

% use kbQueue's as they have high performance
expInfo.useKbQueue = false;
expInfo.enablePowermate = false;

%Lets add an experiment wide setting here:

expInfo.instructions = ['Try to move the mouse left or right to try and follow the changing orientation of the stimuli. Press enter to start'];
     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@rotating_gabor_trial;
conditionInfo(1).giveFeedback = true;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 3; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = .25;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration = 0;    %Post trial window for waiting for a response

conditionInfo(1).sigma=2; %standard deviation of the gabor in degrees
conditionInfo(1).freq = 4; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps = 2; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg  = 6;    %stimulus size in degree;
conditionInfo(1).contrast = 0.25;
conditionInfo(1).noiseSigma = .1;
conditionInfo(1).orientationSigma = 5;
%Implement arbitrary forward models. 
%conditionInfo(1).forwardModel = [ 1 0 ]; %Forward model


conditionInfo(2) = conditionInfo(1);
conditionInfo(2).orientationSigma = 5;
conditionInfo(2).contrast = 0.05 ;





