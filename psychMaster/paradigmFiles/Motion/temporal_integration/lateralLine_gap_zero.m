function [conditionInfo, expInfo] = lateralLine_gap_zero(expInfo)

expInfo = lateralLineDefaultSettings(expInfo);
expInfo.paradigmName = 'lateralLine_gap_zero';

section2velocity = [16 32]; %velocities to use in cm/s; picked randomly for now

for iCond = 1: length(section2velocity);
    conditionInfo(iCond).trialFun=@LateralLineTrial; %This defines what function to call to draw the condition
    conditionInfo(iCond).type = 'generic'; %type of task based on ptbCorgi definition
    conditionInfo(iCond).label = ['zero_gap_' num2str(section2velocity(iCond))]; 
    %the labels for the levels when viewing in ptbCorgi gui
    conditionInfo(iCond).nReps = 10; %number of repeats of the level
    conditionInfo(iCond).isNullCorrect = false; %so the standard isn't the "correct" answer
    
    conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
    conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
    conditionInfo(iCond).stimDurationSection2 = 0.50; %variable in future but for now fixed
    conditionInfo(iCond).temporalGap = 0; %the approximate length of time 
    %in seconds that people will have between section 1 and section 2
    conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
    
    conditionInfo(iCond).velocityCmPerSecSection1 = 10; % velocity of section 1 in cm/s. Constant for this exp
    conditionInfo(iCond).velocityCmPerSecSection2 = section2velocity(iCond); %velocity of section 2 in cm/s
    
    conditionInfo(iCond).startPos = -4; %the start position of the line on the screen in cm 
    %number picked at random for now, will likely be changed later.
    %Negative = left hand side of the screen.

end

end