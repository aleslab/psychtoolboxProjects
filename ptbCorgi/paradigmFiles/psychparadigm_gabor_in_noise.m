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


fixationInfo(1).type  = 'cross';
fixationInfo(1).size  = .5;
fixationInfo(1).lineWidthPix = 2;
fixationInfo(1).color = 1;
expInfo.fixationInfo = fixationInfo;



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
conditionInfo(1).stimDuration     = 0; %approximate stimulus duration in seconds
conditionInfo(1).post  = 1;  %Static time before stimulus change
%conditionInfo(1).postStimMaskDuration =  .5; %mask duration in seconds. 
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = 1;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 3;    %Post trial window for waiting for a response
conditionInfo(1).gaborOrientation = 90;
conditionInfo(1).gaborSigma             =2; %standard deviation of the gabor in degrees
conditionInfo(1).gaborFreq              =1; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).stimSizeDeg     =   8;    %stimulus size in degree;
conditionInfo(1).gaborContrast = 0.50;
conditionInfo(1).noiseSigma = .15;

conditionInfo(1).label = 'center';
conditionInfo(1).gaborCenterY      =   0;%Horizontal location of gabor in degrees
conditionInfo(1).gaborCenterX      =   0;%vertical location

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).label = 'upper left?';

conditionInfo(2).gaborCenterY      =   5;%just rough screen posisitions for now. 
conditionInfo(2).gaborCenterX      =   6.5;%will see where to put in lab

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).label = 'Contrast: 0.50';
conditionInfo(2).label = 'upper right?';
conditionInfo(3).gaborCenterY      =   2;
conditionInfo(3).gaborCenterX      =   2;

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).GaborContrast = 0 ;
conditionInfo(4).label = 'Contrast: 0.50';
conditionInfo(2).label = 'blank';
conditionInfo(4).gaborCenterY      =   2;
conditionInfo(4).gaborCenterX      =   2;

conditionInfo(5) = conditionInfo(1);
conditionInfo(5).label = 'upper left?';
conditionInfo(5).gaborCenterY      =   5;%just rough screen posisitions for now. 
conditionInfo(5).gaborCenterX      =   6.5;%will see where to put in lab



conditionInfo(6) = conditionInfo(1);
conditionInfo(6).label = 'upper left?';
conditionInfo(6).gaborCenterY      =   5;%just rough screen posisitions for now. 
conditionInfo(6).gaborCenterX      =   6.5;%will see where to put in lab

conditionInfo(7) = conditionInfo(1);
conditionInfo(7).label = 'Contrast: 0.50';
conditionInfo(7).label = 'upper right?';
conditionInfo(7).gaborCenterY      =   2;
conditionInfo(7).gaborCenterX      =   2;

conditionInfo(8) = conditionInfo(1);
conditionInfo(8).GaborContrast = 0 ;
conditionInfo(8).label = 'Contrast: 0.50';
conditionInfo(8).label = 'blank';
conditionInfo(8).gaborCenterY      =   2;
conditionInfo(8).gaborCenterX      =   2;



end








