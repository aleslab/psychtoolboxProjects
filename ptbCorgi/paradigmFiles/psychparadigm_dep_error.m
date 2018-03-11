function [conditionInfo,expInfo] = psychparadigm_dep_error(expInfo)
expInfo.paradigmName = 'error_calib';
expInfo.randomizationType = 'blocked';

expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .5;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;
 


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
conditionInfo(1).trialFun=@dep_gabor_trial;
conditionInfo(1).giveFeedback = false;
conditionInfo(1).powermateSpeed = 2;
conditionInfo(1).powermateAccel = 3;



%updateMethod determines how the orientation is updated on a trial by trial
%basis. 
%'brownian' does a random walk like brownian motion and utilizes
%orientationSigma to set the update size.
%'uniform' randomly chooses an orientation from 0-360 degrees on each
%trial.
conditionInfo(1).updateMethod = 'brownian';

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 1;  %Static time before stimulus change

conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = 1;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 0;    %Post trial window for waiting for a response

conditionInfo(1).sigma             =2; %standard deviation of the gabor in degrees
conditionInfo(1).freq              =1; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps             = 5; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg     =   8;    %stimulus size in degree;

conditionInfo(1).contrast = 0.20;
conditionInfo(1).noiseSigma = .15;
conditionInfo(1).orientationSigma = 11.552; %standard dev of the stim orientation change  
%Implement arbitrary forward models. 
%conditionInfo(1).forwardModel = [ 1 0 ]; %Forward model
conditionInfo(1).label = 'Contrast: 0.20';
conditionInfo(1).showFeedbackGabor = false;
conditionInfo(1).gaborCenterX=4;
conditionInfo(1).gaborCenterY=4;

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).contrast = 0.20 ;
conditionInfo(2).label = 'Contrast: 0.20';
conditionInfo(2).showFeedbackGabor = true;
conditionInfo(2).gaborCenterX=2;
conditionInfo(2).gaborCenterY=2;


conditionInfo(3) = conditionInfo(1);
conditionInfo(3).contrast = 0.20 ;
conditionInfo(3).label = 'Contrast: 0.20';
conditionInfo(3).showFeedbackGabor = false;
conditionInfo(3).gaborCenterX=2;
conditionInfo(3).gaborCenterY=2;


conditionInfo(4) = conditionInfo(1);
conditionInfo(4).contrast = 0.20 ;
conditionInfo(4).label = 'Contrast: 0.20';
conditionInfo(4).showFeedbackGabor = true;
conditionInfo(4).gaborCenterX=2;
conditionInfo(4).gaborCenterY=2;





end











