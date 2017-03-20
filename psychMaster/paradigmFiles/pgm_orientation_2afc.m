function [conditionInfo,expInfo] = pgm_orientation_2afc(expInfo)
expInfo.paradigmName = 'OrientTest';
expInfo.randomizationType = 'random';

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
conditionInfo(1).trialFun=@gaborInNoiseTrial;
conditionInfo(1).giveFeedback = true;

%Setup a 2afc experiment that randomizes the field "orientation" and
%increments it
conditionInfo(1).type = '2afc';
conditionInfo(1).randomizeField(1).fieldname = 'orientation';
conditionInfo(1).randomizeField(1).type = 'uniform';
conditionInfo(1).randomizeField(1).param = [0 360];
conditionInfo(1).targetFieldname = 'orientation';
conditionInfo(1).targetDelta = -15;
conditionInfo(1).intervalBeep = true;
conditionInfo(1).giveAudioFeedback = true;



% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 0.5; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0;  %Static time before stimulus change

conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = .5;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 3;    %Post trial window for waiting for a response

conditionInfo(1).sigma             =2; %standard deviation of the gabor in degrees
conditionInfo(1).freq              =1; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps             = 105; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg     =   8;    %stimulus size in degree;

conditionInfo(1).contrast    = 0.50;
conditionInfo(1).noiseSigma  = .15;
conditionInfo(1).orientation = 10; %standard dev of the stim orientation change  
%Implement arbitrary forward models. 
%conditionInfo(1).forwardModel = [ 1 0 ]; %Forward model
conditionInfo(1).label = 'Contrast: 0.50';



end












