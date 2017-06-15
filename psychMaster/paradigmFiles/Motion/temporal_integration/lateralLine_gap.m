function [conditionInfo, expInfo] = lateralLine_gap(expInfo)

expInfo.paradigmName = 'lateralLine_gap';

expInfo.randomizationType = 'blocked';

expInfo.viewingDistance = 92; %in cm; 92 rounded up, it's 91.7 from the screen to the outer edge of the chin rest

%on screen text
expInfo.instructions = 'Did the line speed up or slow down?';
expInfo.pauseInfo = 'Paused\nPress any key to continue';

%Define the fixation marker for the experiment.
expInfo.fixationInfo(1).type    = 'cross';
expInfo.fixationInfo(1).lineWidthPix = 1;
expInfo.fixationInfo(1).size  = .2;
expInfo.conditionGroupingField = 'temporalGap';

section2velocity = [10 20 30 40]; %velocities to use in deg/s;
%section2velocity = [10 12 14 16 18 19 20 21 22 24 26 28 30]; %velocities to use in deg/s;
temporalGap = [0 1 2];

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
    conditionInfo(iCond).stimDurationSection2 = 0.20; %variable in future but for now fixed
    conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
    conditionInfo(iCond).temporalGap = 1; %the approximate length of time
    %in seconds that people will have between section 1 and section 2
    
    
    %velocities
    conditionInfo(iCond).velocityDegPerSecSection1 = 20; % velocity of section 1 in deg/s. Constant for this exp
    conditionInfo(iCond).velocityDegPerSecSection2 = section2velocity(iCond); %velocity of section 2 in deg/s
    conditionInfo(iCond).gapVelocity = 0; %velocity in deg/s for temporal gap
    conditionInfo(iCond).startPos = -8; %the start position of the line on the screen in degrees of visual angle.
    %Negative = left hand side of the screen.
    
end

end
