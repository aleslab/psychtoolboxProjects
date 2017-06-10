function [conditionInfo, expInfo] = lateralLine_gap(expInfo)

expInfo.paradigmName = 'lateralLine_gap';
expInfo.viewingDistance = 92; %in cm; I need to check this
expInfo.instructions = 'Did the line speed up or slow down?';
expInfo.pauseInfo = 'Paused\nPress any key to continue';

%Define the fixation marker for the experiment.
expInfo.fixationInfo(1).type    = 'cross';
expInfo.fixationInfo(1).lineWidthPix = 1;
expInfo.fixationInfo(1).size  = .2;


section2velocity = [0.5 2]; %velocities to use in deg/s; picked randomly for now

for iCond = 1: length(section2velocity);
    %general
    conditionInfo(iCond).trialFun=@LateralLineTrial; %This defines what function to call to draw the condition
    conditionInfo(iCond).type = 'simpleResponse'; %type of task based on ptbCorgi definition
    conditionInfo(iCond).label = ['temporal_Integration_' num2str(section2velocity(iCond))]; 
    %the labels for the levels when viewing in ptbCorgi gui
    conditionInfo(iCond).nReps = 10; %number of repeats of the level
    conditionInfo(iCond).validKeyNames = {'f','j'}; 
    %key presses that will be considered valid responses and not keyboard errors
    
    %timings
    conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
    conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
    conditionInfo(iCond).stimDurationSection2 = 0.50; %variable in future but for now fixed
    conditionInfo(iCond).temporalGap = 0; %the approximate length of time 
    %in seconds that people will have between section 1 and section 2
    conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
    
    %velocities
    conditionInfo(iCond).velocityDegPerSecSection1 = 1; % velocity of section 1 in deg/s. Constant for this exp
    conditionInfo(iCond).velocityDegPerSecSection2 = section2velocity(iCond); %velocity of section 2 in deg/s
    conditionInfo(iCond).gapVelocity = 0; %velocity in deg/s for temporal gap
    conditionInfo(iCond).startPos = -1; %the start position of the line on the screen in degrees of visual angle.
    %Negative = left hand side of the screen.

end

end