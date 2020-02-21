function [conditionInfo,expInfo] = psychPardidgmstep_fischer(expInfo)

expInfo.paradigmName = '_fish_Gabor';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.nbBlockReps = 1;

% use kbQueue's as they have high performance
expInfo.useKbQueue = false;
expInfo.enablePowermate = false;
expInfo.viewingDistance = 57;

%Lets add an experiment wide setting here:

expInfo.instructions = ['Try and align the white line \n' ...
                        'with the orientation of the pattern  \n'...
                        'you have just seen!' ];     


%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).label = 'Contrast: 0.05';
conditionInfo(1).trialFun=@step_gabor_trial_fischer;
conditionInfo(1).giveFeedback = false;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 0.25; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 1;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = 1;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 0;    %Post trial window for waiting for a response
conditionInfo(1).sigma             =2; %standard deviation of the gabor in degrees
conditionInfo(1).freq              =0.1; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps             = 10; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg     =   6;    %stimulus size in degree;
conditionInfo(1).trials_per_step =  8; %how many trials at each orientation 
conditionInfo(1).step_size_deg = 10; %size of step 
conditionInfo(1).contrast = 0.05;
conditionInfo(1).noiseSigma = .15;
conditionInfo(1).orientationSigma = 0;

%Implement arbitrary forward models. 
%conditionInfo(1).forwardModel = [ 1 0 ]; %Forward model
% conditionInfo(1).label = 'Contrast: 0.20';
% 
% conditionInfo(2) = conditionInfo(1);
% conditionInfo(2).orientationSigma = 0;
% conditionInfo(2).contrast = 0.20 ;
% conditionInfo(2).label = 'Contrast: 0.20';
% conditionInfo(2).trialFun=@step_gabor_trial_correct;
% 
% 
% 
% conditionInfo(3) = conditionInfo(1);
% conditionInfo(3).orientationSigma = 0;
% conditionInfo(3).contrast = 0.05;
% conditionInfo(3).label = 'Contrast: 0.05';
% %conditionInfo(3).trials_per_step =  5; %how many trials at each orientation 
% conditionInfo(3).step_size_deg = 60; %size of step 
% conditionInfo(3).trialFun=@step_gabor_trial_correct;
% 
% conditionInfo(4) = conditionInfo(1);
% conditionInfo(4).orientationSigma = 0;
% conditionInfo(4).contrast = 0.20;
% conditionInfo(4).label = 'Contrast: 0.20';
% %conditionInfo(4).trials_per_step =  5; %how many trials at each orientation 
% conditionInfo(4).step_size_deg = 60; %size of step 
% conditionInfo(4).trialFun=@step_gabor_trial_correct;
% 
% % 
% 
% 
% 
% 
% 
% end
% 
% 
% 
% 
