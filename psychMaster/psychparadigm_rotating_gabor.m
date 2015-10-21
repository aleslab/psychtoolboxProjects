function [conditionInfo, ScreenInfo, screenInfo] = psychparadigm_rotating_gabor(screenInfo)
screenInfo.paradigmName = 'noiseDetect';

% use kbQueue's as they have high performance
screenInfo.useKbQueue = false:


%Lets add an experiment wide setting here:
payoff = [ 10 10 -10 -10];
screenInfo.payoff = payoff;

screenInfo.instructions = ['Press f key if target present' ...
         '\nPress f key if target absent\n' ...
         '\n' num2str(payoff(1)) ' points for a hit' ...
         '\n' num2str(payoff(2)) ' points for a correct reject' ...
         '\n' num2str(payoff(3)) ' points for a miss' ...
         '\n ' num2str(payoff(4)) ' points for a false alarm' ...
         '\n\n    Press any key to start'];
%%% Justin**** b unsure about wether to leave all these screen instructions in??
     
%This defines what function to call to draw the condition
conditionInfo(1).trialFun=rotating_gabor_trial;


% %Condition definitions
%Condition 1, lets set some defaults:
%Condition 1 is the target absent condition.
conditionInfo(1).stimDuration     = 0.25; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = .2;     %Inter Stimulus Interval
conditionInfo(1).responseDuration = 2;    %Post trial window for waiting for a response
conditionInfo(1).sigma=.20; %cyclespersigma
conditionInfo(1).freq = 4; %frequency of what ***justin
conditionInfo(1).targetAmp = 0; % targetamplitude **Justin
conditionInfo(1).nReps = 2; %% number of reps **justin
conditionInfo(1).stimRadiusCm   = 5;    %stimulus size in cm;
conditionInfo(1).contrast = 0.25 
conditonInfo(1).orientation = 360*Rand() 



%For conditions 2-4 we're going to copy all the settings from condition 1
%and just define what we want changed.

conditionInfo(2) = conditionInfo(1);
conditionInfo(2).targetAmp = 10;
conditionInfo(2).nReps = 1;

conditionInfo(3) = conditionInfo(1);
conditionInfo(3).targetAmp = 30;
conditionInfo(3).nReps = 1;

conditionInfo(4) = conditionInfo(1);
conditionInfo(4).targetAmp = 80;
conditionInfo(4).nReps = 1;
