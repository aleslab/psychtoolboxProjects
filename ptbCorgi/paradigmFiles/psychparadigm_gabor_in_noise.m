function [conditionInfo,expInfo] = psychparadigm_gabor_in_noise(expInfo)
expInfo.paradigmName = 'gabor_in_noise';


expInfo.trialRandomization.type = 'markov';
expInfo.trialRandomization.nTrials = 20;

expInfo.trialRandomization.transitionMatrix=[.3  0 .2 .5  0  0  0  0;  ...%if in con 1 .2 chance of staying in one
                                             .5  0  0 .5  0  0  0  0; ...
                                             .2 .3 .5  0  0  0  0  0;
                                             .8  0  0 .2  0  0  0  0;
                                              0  0  0  0 .8  0  0 .2;
                                              0  0  0  0  0 .5 .3 .2;
                                              0  0  0  0 .5  0  0 .5;
                                              0  0  0  0 .5 .2  0 .3];
 



% use kbQueue's as they have high performance
expInfo.useKbQueue = false;
expInfo.enablePowermate = false;
expInfo.viewingDistance = 57;

%fixationDuringStimulus=[expInfo.fixationInfo]; %
% fixationInfo(1).type  = 'cross';
% fixationInfo(1).size  = .5;
% fixationInfo(1).lineWidthPix = 2;
% fixationInfo(1).color = 1;
% expInfo.fixationInfo = fixationInfo;



%Lets add an experiment wide setting here:

expInfo.instructions = ['Where is the stimulus? its 10 points for every correct answer\n' ...
                        'sometimes it will be obvious but sometimes it will vanish\n'...
                        'do you still know where it will be ?' ];     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@trial_gaborInNoise;
conditionInfo(1).type='simpleresponse';



% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).preStimDurationMin = 0.2;% minimum time before next stimulus
conditionInfo(1).preStimDurationMu = 0.5; % prestimduration is drawn from a mu expotential distribution which has a "memeoryless" property
conditionInfo(1).stimDuration     = 0.2; %approximate stimulus duration in seconds
% conditionInfo(1). postStimMaskDuration=0; % no real need for a mask here 
conditionInfo(1).gaborCenterX = 0; % going to be around 3 degs but il set this in the lab
conditionInfo(1).gaborCenterY = 0; % see above 
conditionInfo(1).gaborPhase=90; % phase of gabor (i dont actually know what this means)
conditionInfo(1).gaborOrientation = 0; % orientation of Gabor-doest really matter here as long as it is constant 
conditionInfo(1).gaborContrast= .50; % picked 0.5 but anything over 0.20 is ok. 
conditionInfo(1).gaborSigma = 1; % standard dev of gaussian envlope
conditionInfo(1).gaborFreq = 1; % sine wave freq in cycles per degree 
conditionInfo(1).stimSizeDeg = 2; % size of stimulu in degrees
conditionInfo(1).nosie = 0.15; % standard dev of the luminance values for noise mask
conditionInfo(1).label = 'state 1'; % label of position in markov

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).label = 'state 2';
conditionInfo(2).gaborCenterX = 0; % going to be around 3 degs but il set this in the lab
conditionInfo(2).gaborCenterY = 0; % see above

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).label = 'state 3';
conditionInfo(3).gaborCenterY      =   0;
conditionInfo(3).gaborCenterX      =   0;

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).GaborContrast = 0 ;
conditionInfo(3).label = 'state 4 blank';
conditionInfo(4).gaborCenterY      =   0;
conditionInfo(4).gaborCenterX      =   0;


end








