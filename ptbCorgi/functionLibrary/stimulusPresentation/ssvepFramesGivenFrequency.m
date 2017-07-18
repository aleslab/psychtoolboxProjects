function [ framesPerStimCycle, achievedFrequency ] = ssvepFramesGivenFrequency( stimulusFrequency,monitorRefreshRate )
%ssvepFramesGivenFrequency Calculate how many frames are needed for displaying a given frequency.
%[ framesPerStimCycle, achievedFrequency ] = findFramesGivenFrequency( desiredFrequency,monitorRefreshRate )
%
%Calculates how many frames per stimulus cycle are needed to display a
%stimulus at a desired frequency.  
%
%Inputs: 
%stimulusFrequency = Desired stimulus frequency in Hz.
%montirRefreshRate   = Monitor refresh rate in Hz.
%
%Outputs:
%framesPerStimCycle = An even integer number of frames to use per stimulus
%                     cycle to achieve the closest match to the requested
%                     frequency
%achievedFrequency  = The frequency corresponding to the even integer
%                     frames per cycle
%
%
%Example:
%
%[ framesPerStimCycle, achievedFrequency ] = ssvepFramesGivenFrequency(8.3,85)
% 
% The requested frequcny of 8.3 Hz is not achievable with an integer number
% of frames, the closest match is:
% framesPerStimCycle = 10
% achievedFrequency = 8.5000


if nargin<2
    error('2 inputs required: desired frequency and monitor frame rate');
end

if stimulusFrequency>monitorRefreshRate
    error('Requested stimulusFrequency: %g Hz is above the monitor refresh rate of %g Hz. This is impossible to display',...
        stimulusFrequency,monitorRefreshRate);
end

if monitorRefreshRate<30
    warning('Input monitor frame rate is lower than 30 Hz. Are the inputs correct?')
end


stimulusPeriodSecs = 1/stimulusFrequency;
monitorPeriodSecs  = 1/monitorRefreshRate;

%How many monitor refresh cycles fit into a stimulus period?
%This can be a fractional number.
framesPerStimCycle = stimulusPeriodSecs/monitorPeriodSecs;

%We need an even integer number of frames per stim cycle.
%Otherwise there will be an uneven/nonsymmetric duty cycle for the stimulus
framesPerStimCycle = 2*round(framesPerStimCycle/2);

%Give the even integer frames for stimulus required what frequency did we
%actually achieve?
achievedFrequency = 1/(framesPerStimCycle*monitorPeriodSecs);

if abs(achievedFrequency-stimulusFrequency) > .25;

    warning('Achieved frequency: %g Hz differs from requested: %g Hz by more than 0.25 Hz',achievedFrequency,stimulusFrequency);
end

