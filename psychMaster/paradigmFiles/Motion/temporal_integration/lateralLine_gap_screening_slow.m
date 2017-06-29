function [conditionInfo, expInfo] = lateralLine_gap_screening_slow(expInfo)

expInfo.paradigmName = 'lateralLine_gap_screening_slow';

expInfo.viewingDistance = 92; %in cm; 92 rounded up, it's 91.7 from the screen to the outer edge of the chin rest

%on screen text
expInfo.instructions = 'Did the line \nspeed up or slow down?';
expInfo.pauseInfo = 'Paused\nPress any key to continue';

%Define the fixation marker for the experiment.
expInfo.fixationInfo(1).type    = 'cross';
expInfo.fixationInfo(1).lineWidthPix = 1;
expInfo.fixationInfo(1).size  = .3;

%blocking based on the temporal gaps
expInfo.randomizationType = 'random';
expInfo.conditionGroupingField = 'temporalGap';
temporalGap = [0 1];

%velocities
section2velocity = [1 3]; %velocities to use in deg/s;

iCond = 1; %defining here initially to prevent overwriting

for iGap = 1:length(temporalGap);
    
    for iSpeed = 1: length(section2velocity);
        
        conditionInfo(iCond).randomizeField(1).fieldname = 'iti'; %fieldname to randomize.
        conditionInfo(iCond).randomizeField(1).type = 'uniform';
        conditionInfo(iCond).randomizeField(1).param = [0.5 1.5]; %randomise between 0.5 and 1.5s for iti
        
        %general
        conditionInfo(iCond).trialFun=@LateralLineTrial; %This defines what function to call to draw the condition
        conditionInfo(iCond).type = 'simpleResponse'; %type of task based on ptbCorgi definition
        conditionInfo(iCond).label = ['second_speed_' num2str(section2velocity(iSpeed))];
        %the labels for the levels when viewing in ptbCorgi gui
        conditionInfo(iCond).nReps = 10; %number of repeats of the level
        conditionInfo(iCond).validKeyNames = {'f','j'};
        conditionInfo(iCond).giveAudioFeedback = true;
        %key presses that will be considered valid responses and not keyboard errors
        
        %timings
        conditionInfo(iCond).preStimDuration  = 0.25;  %Static time before stimulus change
        conditionInfo(iCond).stimDurationSection1 = 0.50; %approximate stimulus duration in seconds
        conditionInfo(iCond).stimDurationSection2 = 0.20; %variable in future but for now fixed
        conditionInfo(iCond).responseDuration = 3;    %How long participants will have to respond
        conditionInfo(iCond).iti = 0; %this value is unused because iti is randomised
        conditionInfo(iCond).temporalGap = temporalGap(iGap); %the approximate length of time
        %in seconds that people will have between section 1 and section 2
        
        %velocities
        conditionInfo(iCond).velocityDegPerSecSection1 = 2; %velocity of section 1 in deg/s. Constant for this exp
        conditionInfo(iCond).velocityDegPerSecSection2 = section2velocity(iSpeed); %velocity of section 2 in deg/s
        conditionInfo(iCond).gapVelocity = 0; %velocity in deg/s for temporal gap
        conditionInfo(iCond).startPos = -0.8; %the start position of the line on the screen in degrees of visual angle.
        %Negative = left hand side of the screen.
  
        iCond = iCond+1; %so you don't overwrite the conditions you create with each gap
    end
    
    conditionInfo(1).correctKey = 'f'; %first condition is temporal gap 0, 20-10
    conditionInfo(2).correctKey = 'j';%temporal gap 0 20-30
    conditionInfo(3).correctKey = 'f';%temporal gap 1 20-10
    conditionInfo(4).correctKey = 'j';% temporal gap 1 20-30
    
end

end
