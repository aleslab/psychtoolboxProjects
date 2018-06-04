function [conditionInfo,expInfo] = psychparadigm_gabor_in_noise(expInfo)
expInfo.paradigmName = 'gabor_in_noise';


expInfo.trialRandomization.type = 'blockedmarkov';
expInfo.trialRandomization.nTrials = 100;

expInfo.trialRandomization.transitionMatrix=[1/9 6/9 1/9 1/9
                                             1/9 1/9 6/9 1/9
                                             6/9 1/9 1/9 1/9
                                             1/3 1/3 1/3 0];

expInfo.trialRandomization.type = 'blockedMarkov';
   markovInfo(1).conditionList = [1 2 3 4];
   markovInfo(1).transitionMatrix = [1/9 6/9 1/9 1/9
                                     1/9 1/9 6/9 1/9
                                     6/9 1/9 1/9 1/9
                                     1/3 1/3 1/3 0];
   markovInfo(1).nTrials = 80;
   markovInfo(2).conditionList = [5 6 7 8];
   markovInfo(2).transitionMatrix = [1/9 1/9 6/9 1/9
                                     6/9 1/9 1/9 1/9
                                     1/9 6/9 1/9 1/9
                                     1/3 1/3 1/3 0];
   markovInfo(2).nTrials = 20;
   expInfo.trialRandomization.markovInfo = markovInfo;
   expInfo.trialRandomization.groupOrder = [1 2 1 2 1 2]; % Say
  


% use kbQueue's as they have high performance
expInfo.useKbQueue = true;
expInfo.enablePowermate = false;
expInfo.viewingDistance = 57;


fixationInfo(1).type  = 'cross';
fixationInfo(1).size  = .5;
fixationInfo(1).lineWidthPix = 2;
fixationInfo(1).color = 1;
expInfo.fixationInfo = fixationInfo;

expInfo.conditionGroupingField = 'markovDir';

%Lets add an experiment wide setting here:

expInfo.instructions = ['Where is the stimulus? its 10 points for every correct answer\n' ...
                        'sometimes it will be obvious but sometimes it will vanish\n'...
                        'do you still know where it will be ?' ];     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@trial_gaborInNoise;
conditionInfo(1).type='simpleresponse';
conditionInfo(1).markovDir = 1;


% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).preStimDurationMin = 0.2;% minimum time before next stimulus
conditionInfo(1).preStimDurationMu = 0.5; % prestimduration is drawn from a mu expotential distribution which has a "memeoryless" property
conditionInfo(1).stimDuration     = 0.2; %approximate stimulus duration in seconds
conditionInfo(1).postStimMaskDuration=0; % no real need for a mask here 
conditionInfo(1).gaborCenterX = -3.5355; % going to be around 3 degs but il set this in the lab
conditionInfo(1).gaborCenterY = 3.5355; % see above 
conditionInfo(1).gaborPhase=90; % phase of gabor (i dont actually know what this means)
conditionInfo(1).gaborOrientation = 0; % orientation of Gabor-doest really matter here as long as it is constant 
conditionInfo(1).gaborContrast= .25; % picked 0.5 but anything over 0.20 is ok. 
conditionInfo(1).gaborSigma = 1; % standard dev of gaussian envlope
conditionInfo(1).gaborFreq = 0.1; % sine wave freq in cycles per degree 
conditionInfo(1).stimSizeDeg = 12; % size of stimulu in degrees
conditionInfo(1).nosieSigma = 0.001; % standard dev of the luminance values for noise mask
conditionInfo(1).label = 'state 1'; % label of position in markov

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).label = 'state 2';
conditionInfo(2).gaborCenterX = 0; % going to be around 3 degs but il set this in the lab
conditionInfo(2).gaborCenterY = 5; % see above

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).label = 'state 3';
conditionInfo(3).gaborCenterX     =  3.5355;
conditionInfo(3).gaborCenterY     =  3.5355 ;

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).gaborContrast = 0 ;
conditionInfo(4).label = 'blank';
conditionInfo(4).gaborCenterY      =   0;
conditionInfo(4).gaborCenterX      =   0;



conditionInfo(5)=conditionInfo(1);
conditionInfo(5).label = 'rev state 1';
conditionInfo(5).markovDir = 2;

conditionInfo(6)=conditionInfo(2);
conditionInfo(6).label = 'rev state 2';
conditionInfo(6).markovDir = 2;

conditionInfo(7)=conditionInfo(3);
conditionInfo(7).label = 'rev state 3';
conditionInfo(7).markovDir = 2;

conditionInfo(8)=conditionInfo(4);
conditionInfo(8).label = 'rev blank';
conditionInfo(8).markovDir = 2;



end








