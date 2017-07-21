function [trialData] = testTrigger(expInfo, conditionInfo)

ptbCorgiSendTrigger(expInfo,'raw',0,64);
t = Screen('Flip', expInfo.curWindow);
trialData.t(1) = t;

Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]); % black
ptbCorgiSendTrigger(expInfo,'raw',0,1);
newt= Screen('Flip', expInfo.curWindow, t + 0.6 );
trialData.t(2) = newt;

Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]); % white
ptbCorgiSendTrigger(expInfo,'raw',0,0);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.6 );
trialData.t(3) = newt;

Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,1);
t = newt;
newt= Screen('Flip', expInfo.curWindow, t + 0.6 );
trialData.t(4) = newt;

Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,4);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.6);
trialData.t(5) = newt;

Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,1);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.6 );
trialData.t(6) = newt;

Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,0);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.6);
trialData.t(7) = newt;

Screen('FillRect', expInfo.curWindow, [0 0 0],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,4);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.6);
trialData.t(8) = newt;

Screen('FillRect', expInfo.curWindow, [1 1 1],[0 0 100 100]); 
ptbCorgiSendTrigger(expInfo,'raw',0,65);
t = newt;
newt = Screen('Flip', expInfo.curWindow, t + 0.8);
trialData.t(9) = newt;

end

% diff(experimentData.trialData.t)