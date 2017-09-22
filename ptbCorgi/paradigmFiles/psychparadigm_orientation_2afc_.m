function [conditionInfo,expInfo] = psychparadigm_orientation_2afc(expInfo)
%This is an example paradigm file that implements an orienatation
%discrimination task. 


%Define things that are set in expInfo for the whole experiment

%Paradigm Name is a short name that identifies this paradigm
expInfo.paradigmName = 'OrientationDiscrimination';

%Randomly present each condition.
expInfo.randomizationType = 'blocked';
expInfo.randomizationOptions.blockConditionsByField = ['contrast'] ;

%Define the viewing distance.
expInfo.viewingDistance = 57;

%Setup a simple fixation cross.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .5;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

%Instructions are displayed once at the begining of an experiment
expInfo.instructions = ['This is an orientation discrimination experiment\n' ...
    'Please judge whether or not the 2nd stimulus rotates clockwise\n' ...
    'or anticlockwise from the 1st\n' ...
    'Wait till the box appears before responding\n' ...
    'Press ''j'' for clockwise \n'...
    'Press ''f'' for anticlockwise\n'];

%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@gaborInNoiseTrial;


%Setup a 2-interval forced choice experiment that randomizes the field "orientation" and
%changes it by "targetDelta" between each interval.
conditionInfo(1).type = '2afc'; %2 interval forced choice

%For this paradigm we want the gabor to take a random orientation
%so we will use the "randomizeField" option.
conditionInfo(1).randomizeField(1).fieldname = 'orientation'; %fieldname to randomize
%We'll use a uniform distribtion on 0 to 360 for the setting.
conditionInfo(1).randomizeField(1).type = 'uniform'; 
conditionInfo(1).randomizeField(1).param = [0 360];

%One way to create a 2afc paradigm is to use  "targetFieldname" 
%
conditionInfo(1).targetFieldname = 'orientation'; %Field to 
conditionInfo(1).targetDelta = -15; %This is an example to subtract 15 from 'orientation' Actual values get set in the loop below

%Feedback options
conditionInfo(1).intervalBeep = false; %Should we play beeps that identify the two intervals?
conditionInfo(1).giveAudioFeedback = false; %Should we play 
conditionInfo(1).giveFeedback = false; %Should we give written feedback after each trial?

% %Condition definitions
%These fields are 
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration             = 0.5; %Gabor stimulus duration in seconds
conditionInfo(1).postStimMaskDuration     = 1; %Noise mask duration in seconds

conditionInfo(1).iti              = .2;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration  = 3;    %Post trial window for waiting for a response

%Gabor parameters
conditionInfo(1).sigma             = 2; %standard deviation of the gabor in degrees
conditionInfo(1).freq              = 1; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).nReps             = 3; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusDeg     = 8;    %stimulus size in degree;
conditionInfo(1).orientation       = 0; %Unused in this paradigm because it gets set by the randomization option (randomizeField) above
conditionInfo(1).contrast          = 10;
conditionInfo(1).noiseSigma        = .15;


%Now we'll build up the conditions
%First we create a list of orientations
%These are negative (-) because a negative orientation change is clockwise
%That makes the task consistent with the instructions


orientationDeltaList = linspace(-0.25,-5,7);
orientationDeltaList = repmat (orientationDeltaList, 1,2);
contrastList = [repmat(0.05,1,7) repmat(0.20, 1,7)];

nCond= length (orientationDeltaList);


for iCond = 1:nCond,
    
    %First set all the parameters to the values we set above.
    conditionInfo(iCond) = conditionInfo(1);
    
    %Now setup the delta for this condition
    conditionInfo(iCond).targetDelta = orientationDeltaList(iCond);
    
    %now set tp chnge of contrast in for loop
    conditionInfo(iCond).contrast = contrastList (iCond);
    
    %We can give each condition a human readable lable. 
    conditionInfo(iCond).label = ['Ori: ' num2str(conditionInfo(iCond).targetDelta) ...
        'Con' num2str(conditionInfo(iCond).contrast) ];


end


% conditionInfo(3) = conditionInfo(1);
% conditionInfo(3).contrast = 0.40 ;
% conditionInfo(3).label = 'Contrast: 0.40';














