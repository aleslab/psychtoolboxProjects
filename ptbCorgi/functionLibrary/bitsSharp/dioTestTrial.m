function [trialData] = dioTestTrial(expInfo, conditionInfo)

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow,[],1);
trialDuration = 10;
stimulusRect = CenterRect([0 0  expInfo.windowSizePixels/2],expInfo.screenRect);
F1  = conditionInfo.F1;
period = 1/F1;

ptbCorgiSendTrigger(expInfo,'raw',1,2^3+2^5); %Send a trigger now
prevFlip = t;
while prevFlip < t+trialDuration
    
    ptbCorgiSendTrigger(expInfo,'raw',0,55); %Schedule a toggle trigger for next flip
 %   ptbCorgiSendTrigger(expInfo,'togglebit',0); %Schedule a toggle trigger for next flip
 
   
    Screen('fillrect',expInfo.curWindow,0,stimulusRect)
    prevFlip=Screen('flip',expInfo.curWindow,prevFlip+period/2+expInfo.ifi/2);

    
    Screen('fillrect',expInfo.curWindow,1,stimulusRect)
    ptbCorgiSendTrigger(expInfo,'raw',0,413); %Schedule a toggle trigger for next flip
 
%    ptbCorgiSendTrigger(expInfo,'togglebit',0)
    prevFlip=Screen('flip',expInfo.curWindow,prevFlip+period/2+expInfo.ifi/2);

end

ptbCorgiSendTrigger(expInfo,'clear',1);
trialData.startTime = t;

