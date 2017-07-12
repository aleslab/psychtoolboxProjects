function [conditionInfo, expInfo] = pdgm_ssvepGratingReversal(expInfo)

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'exampleGratingReversal';
expInfo.useBitsSharp = true;
expInfo.enableTriggers = true;

expInfo.instructions = 'Instructions can go here.';

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .5;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;


%% conditions

%This defines what function to call to draw the condition
conditionInfo(1).trialFun=@ssvepGratingReversal;
conditionInfo(1).nReps = 20; %number of repeats

conditionInfo(1).iti  = 2; % Inter trial interval in seconds
conditionInfo(1).type = 'generic'; % Generic trial type. 
conditionInfo(1).sizeDeg = 8; %Size of the grating patch in degrees
conditionInfo(1).spatialFrequencyDeg = 1; %Spatial frequency of the grating
conditionInfo(1).contrast =1; %Grating contrast
conditionInfo(1).temporalFrequency   = 8; %temporal frequency in Hz. 
conditionInfo(1).prePostDurSecs = 1; % Amount of time to prefix and postfix to the stimulus
conditionInfo(1).stimDurSecs = 1;    %Amount of time to display the stimulus for. 
conditionInfo(1).responseDuration = 0;    %Post trial window for waiting for a response
conditionInfo(1).aperture = 'square'; %Aperture shape can either be 'square', or 'circle'

