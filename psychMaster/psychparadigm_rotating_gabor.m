function [conditionInfo,expInfo] = psychparadigm_rotating_gabor(expInfo)
expInfo.paradigmName = 'rotatingGabor';

% use kbQueue's as they have high performance
expInfo.useKbQueue = false;

expInfo.powermateId =1;
expInfo.enablePowermate = true;
expInfo.useFullScreen = false;

%Lets add an experiment wide setting here:

expInfo.instructions = ['Move your mouse left and right to match the orientation of the gabor'];
     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@rotating_gabor_trial;
conditionInfo(1).giveFeedback = true;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 20; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 1.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = 1;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration = 0;    %Post trial window for waiting for a response

conditionInfo(1).sigma=1; %standard deviation of the gabor in degrees
conditionInfo(1).freq = 4; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps = 1; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg  = 3;    %stimulus size in degree;
conditionInfo(1).contrast = 0.25;
conditionInfo(1).noiseSigma = .1;
conditionInfo(1).orientationSigma = 5;
%Implement arbitrary forward models. 
%conditionInfo(1).forwardModel = [ 1 0 ]; %Forward model


conditionInfo(2) = conditionInfo(1);
conditionInfo(2).orientationSigma = 5;
conditionInfo(2).contrast = 0.05 ;





