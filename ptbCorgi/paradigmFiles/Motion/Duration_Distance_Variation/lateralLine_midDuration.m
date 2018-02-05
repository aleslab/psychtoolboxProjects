function [conditionInfo, expInfo] = lateralLine_midDuration(expInfo)

%paradigm for exp 6 (experiment investigating the role of distance and 
%duration in speed discrimination).

expInfo.paradigmName = 'lateralLine_midDuration';

expInfo.viewingDistance = 92; %in cm; 92 rounded up, it's 91.7 from the screen to the outer edge of the chin rest

%on screen text
expInfo.instructions = 'Did the line \nspeed up or slow down?';
expInfo.pauseInfo = 'Paused\nPress any key to continue';

%Define the fixation marker for the experiment.
expInfo.fixationInfo(1).type    = 'cross';
expInfo.fixationInfo(1).lineWidthPix = 1;
expInfo.fixationInfo(1).size  = .3;

%velocities
section2velocity = [6.7032 7.6593 8.7517 10.0000 11.4263 13.0561 14.9182]; %velocities to use in deg/s;

iCond = 1; %defining here initially to prevent overwriting

%for iGap = 1:length(spatialGap);
    
    for iSpeed = 1: length(section2velocity);
        
        conditionInfo(iCond).randomizeField(1).fieldname = 'iti'; %fieldname to randomize.
        conditionInfo(iCond).randomizeField(1).type = 'uniform';
        conditionInfo(iCond).randomizeField(1).param = [0.5 1.5]; %randomise between 0.5 and 1.5s for iti
        
        %general
        conditionInfo(iCond).trialFun=@LateralLineTrial; %This defines what function to call to draw the condition
        conditionInfo(iCond).type = 'simpleResponse'; %type of task based on ptbCorgi definition
        conditionInfo(iCond).label = ['mid_dur_second_speed_' num2str(section2velocity(iSpeed))];
        %the labels for the levels when viewing in ptbCorgi gui
        conditionInfo(iCond).nReps = 10; %number of repeats of the level
        conditionInfo(iCond).validKeyNames = {'f','j'};
        %key presses that will be considered valid responses and not keyboard errors
        
        %timings
        conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
        conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
        conditionInfo(iCond).stimDurationSection2 = 0.50; %variable in future but for now fixed
        conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
        conditionInfo(iCond).iti = 0; %this value is unused because iti is randomised
        %conditionInfo(iCond).spatialGap = spatialGap(iGap); %the spatial gap in the
        %Y axis between section 1 and 2
        
        conditionInfo(iCond).temporalGap = 0; %the approximate length of time
        %in seconds that people will have between section 1 and section 2
        
        %velocities
        conditionInfo(iCond).velocityDegPerSecSection1 = 10; %velocity of section 1 in deg/s. Constant for this exp
        conditionInfo(iCond).velocityDegPerSecSection2 = section2velocity(iSpeed); %velocity of section 2 in deg/s
        conditionInfo(iCond).gapVelocity = 0; %velocity in deg/s for temporal gap
        conditionInfo(iCond).startPos = -5; %the start position of the line on the screen in degrees of visual angle.
        %Negative = left hand side of the screen.
        
        iCond = iCond+1; %so you don't overwrite the conditions you create with each gap
    end
    
%end

end
