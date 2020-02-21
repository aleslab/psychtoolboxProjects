function [conditionInfo,expInfo] = psychparadigm_gabor_in_noise(expInfo)


%Randomize base orientation at paraidgm load%
%!!!%
orientA = rand()*360;

expInfo.paradigmName = 'FuzzySummerfield';


expInfo.trialRandomization.type = 'custom';

%Create custom random trial list

trialsPerBlock=2;
nBlockReps=5;

trialList = [];
blockList = [];
thisBlock = 0;
startChoice = round(rand());
for iBlockRep = 1:nBlockReps,
    
    thisBlockRand = round(rand(1,trialsPerBlock))+2 + startChoice*3;
    instCond      = 1 + startChoice*3;
    thisBlockTrialList = [instCond thisBlockRand];
    trialList = [trialList thisBlockTrialList]
    thisBlock = thisBlock+1;
    blockList = [blockList thisBlock*ones(size(thisBlockTrialList))];
    
    
    thisBlockRand = round(rand(1,trialsPerBlock))+2 + (1-startChoice)*3;
    instCond      = 1 + (1-startChoice)*3;
    thisBlockTrialList = [instCond thisBlockRand];
    trialList = [trialList thisBlockTrialList]
    thisBlock = thisBlock+1;
    blockList = [blockList thisBlock*ones(size(thisBlockTrialList))];
    
    
    
end

expInfo.trialRandomization.trialList=trialList;
expInfo.trialRandomization.blockList=blockList;


% use kbQueue's as they have high performance
expInfo.useKbQueue = true;
expInfo.enablePowermate = false;
expInfo.viewingDistance = 57;
expInfo.enableBitsRTBox = true;


fixationInfo(1).type  = 'cross';
fixationInfo(1).size  = .5;
fixationInfo(1).lineWidthPix = 2;
fixationInfo(1).color = 1;
expInfo.fixationInfo = fixationInfo;

%PreStimFixation
fixationPreStimulus(1) = fixationInfo;
fixationPreStimulus(2).type = 'square';
fixationPreStimulus(2).size  = .5;
fixationPreStimulus(2).lineWidthPix = 2;
fixationPreStimulus(2).color = 1;

%Lets add an experiment wide setting here:

expInfo.instructions = ['' ];     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@trial_summerfieldInstructions;
conditionInfo(1).type='generic';
conditionInfo(1).label = 'A/B instructions'; % label of position in markov
conditionInfo(1).orientA = orientA;
conditionInfo(1).instructionType = 'a/b';
conditionInfo(1).iti = 2;

%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(2).trialFun=@trial_gaborInNoise;
conditionInfo(2).type='simpleresponse';



% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(2).iti = 0;
conditionInfo(2).preStimDurationMin = 1;% minimum time before next stimulus
conditionInfo(2).preStimDurationMu = 0.5; % prestimduration is drawn from a mu expotential distribution which has a "memeoryless" property
conditionInfo(2).stimDuration     = 1; %approximate stimulus duration in seconds
conditionInfo(2).postStimMaskDuration=0; % no real need for a mask here 
conditionInfo(2).gaborCenterX = 0; 
conditionInfo(2).gaborCenterY = 0; 
conditionInfo(2).gaborPhase=90; % phase of gabor (i dont actually know what this means)

conditionInfo(2).gaborOrientation = 0; %randomize this
%For this paradigm we want the gabor to take a random starting orientation
%on each trial, we will use the "randomizeField" option to accomplish that
conditionInfo(2).randomizeField(1).fieldname = 'gaborOrientation'; %fieldname to randomize
%We'll use a uniform distribtion on 0 to 360 for the setting.
conditionInfo(2).randomizeField(1).type = 'uniform'; 
conditionInfo(2).randomizeField(1).param = [-30 30]+orientA;


conditionInfo(2).gaborContrast= .11; % picked 0.5 but anything over 0.20 is ok. 
conditionInfo(2).gaborSigma = 1; % standard dev of gaussian envlope
conditionInfo(2).gaborFreq = 1.6; % sine wave freq in cycles per degree 
conditionInfo(2).stimSizeDeg = 12; % size of stimulu in degrees
conditionInfo(2).noiseSigma = .05; % standard dev of the luminance values for noise mask
conditionInfo(2).label = 'A'; % label of position in markov
conditionInfo(2).fixationPreStimulus =  fixationPreStimulus;

conditionInfo(3) = conditionInfo(2);
conditionInfo(3).label = 'B';
conditionInfo(3).gaborOrientation = 0; %randomize this
%For this paradigm we want the gabor to take a random starting orientation
%on each trial, we will use the "randomizeField" option to accomplish that
conditionInfo(3).randomizeField(1).fieldname = 'gaborOrientation'; %fieldname to randomize
%We'll use a uniform distribtion on 0 to 360 for the setting.
conditionInfo(3).randomizeField(1).type = 'uniform'; 
conditionInfo(3).randomizeField(1).param = [-30 30]+orientA+60;



%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(4).trialFun=@trial_summerfieldInstructions;
conditionInfo(4).type='generic';
conditionInfo(4).label = 'A/~A instructions'; % label of position in markov
conditionInfo(4).orientA = orientA;
conditionInfo(4).instructionType = 'a/~a';
conditionInfo(4).iti = 2;

conditionInfo(5) = conditionInfo(2);
conditionInfo(5).label = 'A';
conditionInfo(5).gaborOrientation = 0; %randomize this
%For this paradigm we want the gabor to take a random starting orientation
%on each trial, we will use the "randomizeField" option to accomplish that
conditionInfo(5).randomizeField(1).fieldname = 'gaborOrientation'; %fieldname to randomize
%We'll use a uniform distribtion on 0 to 360 for the setting.
conditionInfo(5).randomizeField(1).type = 'uniform'; 
conditionInfo(5).randomizeField(1).param = [-30 30]+orientA;

conditionInfo(6) = conditionInfo(2);
conditionInfo(6).label = '~A';
conditionInfo(6).gaborOrientation = 0; %randomize this
%For this paradigm we want the gabor to take a random starting orientation
%on each trial, we will use the "randomizeField" option to accomplish that
conditionInfo(6).randomizeField(1).fieldname = 'gaborOrientation'; %fieldname to randomize
%We'll use a uniform distribtion on 0 to 360 for the setting.
conditionInfo(6).randomizeField(1).type = 'uniform'; 
conditionInfo(6).randomizeField(1).param = [-30 30]+orientA+60;


end








