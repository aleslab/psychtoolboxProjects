function [trialData] = ContSimultDotTrial(expInfo, conditionInfo)

%AL's code for the dot conditions within the line vs. dots experiment.

% Should have a circular apeture with a 12 degree diameter, split into two
% halves. There should then be 200 dots in each half which wrap around in a
% new location when they disappear. The dots should be ~0.2 deg in
% diameter? and they should be white (like the lines)

trialData.validTrial = true; %Set this to true if you want the trial to be valid for 'generic'
trialData.abortNow   = false;

dotSize = 4; %in pixels, need to change this later
center1 = expInfo.center(1) - round(expInfo.pixPerDeg * 3); % hardcoded - does the centre 3 deg to the left of fixation
center2 = expInfo.center(1) + round(expInfo.pixPerDeg * 3); %does the centre 3 deg to the right

%Draw fixation. Take the parameters from the default fixation set in
%expInfo.
drawFixation(expInfo, expInfo.fixationInfo);
vbl=Screen('Flip', expInfo.curWindow);

%number of frames based on the duration of the section
nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
nFramesSection1 = round(conditionInfo.stimDurationSection1 / expInfo.ifi);
nFramesSection2 = round(conditionInfo.stimDurationSection2/ expInfo.ifi);
nFramesTotal = nFramesPreStim + nFramesSection1 + nFramesSection2;

%saving the information about frames to trial data struct
trialData.nFrames.PreStim = nFramesPreStim;
trialData.nFrames.Section1 = nFramesSection1;
trialData.nFrames.Section2 = nFramesSection2;
trialData.nFrames.Total = nFramesTotal;

%velocity conversions to pixels per second
velSection1PixPerSec = conditionInfo.velocityDegPerSecSection1*expInfo.pixPerDeg;
velSection2PixPerSec = conditionInfo.velocityDegPerSecSection2*expInfo.pixPerDeg;
gapVelocityPixPerSec = conditionInfo.gapVelocity*expInfo.pixPerDeg;

trialData.flipTimes = NaN(nFramesTotal,1);
trialData.LinePos = NaN(nFramesTotal,1);
frameIdx = 1;

%% creating the moving dots

%need to create a matrix of dots in random positions within the aperture
%using rand and multiplying those by the limits. it might be easier to do
%this with a rectangle first before attempting to make it work as a semi
%circle. relevant - circumference of circle = 2piR, area = piR^2 - semi
%circle: c: piR, a: 0.5piR^2

% Usage of drawdots: [minSmoothPointSize, maxSmoothPointSize, minAliasedPointSize,...
%maxAliasedPointSize]=...
%Screen(?DrawDots?, windowPtr, xy [,size] [,color] [,center] [,dot_type][, lenient]);

Screen('DrawDots', expInfo.curWindow, xymatrix, dotsize, center1, 1, 2);

end