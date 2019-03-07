function [trialData] = ContSimultDotTrial(expInfo, conditionInfo)

%AL's code for the dot conditions within the line vs. dots experiment.

% Should have a circular apeture with a 12 degree diameter, split into two
% halves. There should then be 200 dots in each half which wrap around in a
% new location when they disappear. The dots should be ~0.2 deg in
% diameter? and they should be white (like the lines)

trialData.validTrial = true; %Set this to true if you want the trial to be valid for 'generic'
trialData.abortNow   = false;

%Draw fixation. Take the parameters from the default fixation set in
%expInfo.
drawFixation(expInfo, expInfo.fixationInfo);
vbl=Screen('Flip', expInfo.curWindow);



end