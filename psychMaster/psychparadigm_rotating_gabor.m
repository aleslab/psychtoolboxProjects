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
% No. These instructions are for the other paradigm. You'll need to write
% your own. 
     
%This defines what function to call to draw the condition
%Crucial: requires the @ sign prefix.  Because it needs it to be a
%"function handle"
conditionInfo(1).trialFun=@rotating_gabor_trial;


% %Condition definitions
%Condition 1, lets set some defaults:
conditionInfo(1).stimDuration     = 0.25; %approximate stimulus duration in seconds
conditionInfo(1).preStimDuration  = 0.5;  %Static time before stimulus change
conditionInfo(1).postStimDuration = 0;  %static time aftter stimulus change
conditionInfo(1).iti              = .2;     %Minimum Inter Trial Interval
conditionInfo(1).responseDuration = 2;    %Post trial window for waiting for a response

conditionInfo(1).sigma=.20; %standard deviation of the gabor in pixels
conditionInfo(1).freq = 4; %frequency of the gabor in cycles per sigma. 
conditionInfo(1).targetAmp = 0; % target amplitude **Justin This was to define the target in noise
conditionInfo(1).nReps = 2; %% number of trials to present this condition. 
conditionInfo(1).stimRadiusCm   = 5;    %stimulus size in cm;
conditionInfo(1).contrast = 0.25 ;

%This will pick a random orientation at the start of the experiment this is
%not what you want.  
conditionInfo(1).orientation = 360*Rand(); %



