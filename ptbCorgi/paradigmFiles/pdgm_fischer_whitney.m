function [conditionInfo,expInfo] = pdgm_fischer_whitney(expInfo)
expInfo.paradigmName = 'fischerWhitneyRep';
expInfo.randomizationType = 'blocked';


% use kbQueue's as they have high performance
expInfo.useKbQueue = false;
expInfo.enablePowermate = false;
expInfo.enableKeyboard  = false;
expInfo.viewingDistance = 57;

fixationInfo(1).type  = 'cross';
fixationInfo(1).size  = .5;
fixationInfo(1).lineWidthPix = 2;
fixationInfo(1).color = 1;
expInfo.fixationInfo = fixationInfo;

% if expInfo.enablePowermate
%     dev = PsychHID('devices');
%     
%     for iDev = 1:length(dev)
%         
%         if  dev(iDev).vendorID== 1917 && dev(iDev).productID == 1040
%             expInfo.powermateId = iDev;
%             break;
%         end
%     end
% end


%Lets add an experiment wide setting here:

expInfo.instructions = ['Try and align the white line \n' ...
                        'with the orientation of the pattern  \n'...
                        'you have just seen!' ];     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"

conditionInfo(1).trialFun=@fischer_whitney_trial;
conditionInfo(1).giveFeedback = false;
conditionInfo(1).showFeedbackGabor = false;

% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0;  %Static time before stimulus change

conditionInfo(1).noiseDuration = 1;  %static time aftter stimulus change

conditionInfo(1).iti              = 1;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 0;    %Post trial window for waiting for a response

conditionInfo(1).sigma             = 1.5; %standard deviation of the gabor in degrees
%cycles/sigma *sigma/deg = cycles per deg
%Therefore cycles/deg * deg/sigma = cycles per sigma:
conditionInfo(1).freq              = .33*conditionInfo(1).sigma; % frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps             = 50; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg     =   10;    %stimulus size in degree;
conditionInfo(1).gaborCenterY      =   0;
conditionInfo(1).gaborCenterX      =   6.5;
conditionInfo(1).noiseSmoothSigma  = 0.91; %Gaussian Smoothing value for noise in degrees. 


conditionInfo(1).gaborContrast = 0.25;
conditionInfo(1).noiseContrast = .25;

conditionInfo(1).orientationSigma = 5;
conditionInfo(1).label = 'c1';











