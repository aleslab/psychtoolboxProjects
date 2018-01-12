function [conditionInfo, expInfo] = lateralLine_speedchange_fixed_distance(expInfo)

%paradigm for speed change experiment (exp 5). Unbalanced condition:
%distance is fixed.

expInfo.paradigmName = 'lateralLine_speedchange_fixed_distance';

expInfo.viewingDistance = 92; %in cm; 92 rounded up, it's 91.7 from the screen to the outer edge of the chin rest

%on screen text
expInfo.instructions = 'Which one changed speed?';
expInfo.pauseInfo = 'Paused\nPress any key to continue';

%Define the fixation marker for the experiment.
expInfo.fixationInfo(1).type    = 'cross';
expInfo.fixationInfo(1).lineWidthPix = 1;
expInfo.fixationInfo(1).size  = .3;

%velocities
section2velocity = [10 12 14 16 18 20 22]; %velocities to use in deg/s;

section2duration = [0.5 0.4167 0.3571 0.3125 0.2778 0.2500 0.2273];

iCond = 1; %defining here initially to prevent overwriting

for iSpeed = 1: length(section2velocity);
    
    conditionInfo(iCond).randomizeField(1).fieldname = 'iti'; %fieldname to randomize.
    conditionInfo(iCond).randomizeField(1).type = 'uniform';
    conditionInfo(iCond).randomizeField(1).param = [0.5 1.5]; %randomise between 0.5 and 1.5s for iti
    
    %general
    conditionInfo(iCond).trialFun=@LateralLineTrial; %This defines what function to call to draw the condition
    conditionInfo(iCond).type = '2afc'; %type of task based on ptbCorgi definition
    conditionInfo(iCond).label = ['second_speed_' num2str(section2velocity(iSpeed))];
    %the labels for the levels when viewing in ptbCorgi gui
    conditionInfo(iCond).nReps = 10; %number of repeats of the level
    conditionInfo(iCond).validKeyNames = {'f','j'};
    %key presses that will be considered valid responses and not keyboard errors
    conditionInfo(iCond).intervalBeep = true; %will beep to indicate intervals
    
    %timings
    conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
    conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
    conditionInfo(iCond).stimDurationSection2 = section2duration(iSpeed); %variable in future but for now fixed
    conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
    conditionInfo(iCond).iti = 0; %this value is unused because iti is randomised
    conditionInfo(iCond).temporalGap = 0; %the approximate length of time
    %in seconds that people will have between section 1 and section 2. Here
    %we always want a temporal gap of 0.
    
    %velocities
    conditionInfo(iCond).velocityDegPerSecSection1 = 10; %velocity of section 1 in deg/s. Constant for this exp
    conditionInfo(iCond).velocityDegPerSecSection2 = section2velocity(iSpeed); %velocity of section 2 in deg/s
    conditionInfo(iCond).gapVelocity = 0; %velocity in deg/s for temporal gap
    conditionInfo(iCond).startPos = -5; %the start position of the line on the screen in degrees of visual angle.
    %Negative = left hand side of the screen.
    
    
    %defining the null condition
    nullCondition = conditionInfo(iCond); %setting it to be the same as other conditions
    nullCondition.velocityDegPerSecSection1 = 10;  %then always setting the velocity to be the standard
    nullCondition.velocityDegPerSecSection2 = 10; %in both sections
    nullCondition.stimDurationSection2 = 0.5;
    conditionInfo(iCond).nullCondition = nullCondition; %putting it as a field to be accessed within the condition info struct
    
    
    iCond = iCond+1; %so you don't overwrite the conditions you create with each gap
end

