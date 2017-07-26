function [ responseData ] = getResponse(expInfo,responseDuration)
%getResponse - Gets a response with a specified response time window.
%   [ responseData ] = getResponse(expInfo,responseDuration)
%   Detailed explanation goes here

startTime = GetSecs;

%Now lets setup response gathering
%KBqueue's are the better way to get responses, quick and accurate but they can be
%fragile on different systems
if expInfo.useKbQueue
    
    %keysOfInterest=zeros(1,256);
    %keysOfInterest(KbName({'f' 'j' 'ESCAPE'}))=1;
    keysOfInterest=ones(1,256);
    KbQueueCreate(expInfo.inputDeviceNumber, keysOfInterest);
    KbQueueStart(expInfo.inputDeviceNumber);    
    %Flush any events that happend before the end of the trial
    KbQueueFlush();
    
end

curTime = GetSecs;
%Now fire a busy loop to process any keypress durring the response window.
while curTime<startTime+responseDuration
        
    if expInfo.useKbQueue
        [ responseData.pressed, responseData.firstPress]=KbQueueCheck(expInfo.inputDeviceNumber);
    else
        [ responseData.pressed, secs, keyCode]=KbCheck(expInfo.inputDeviceNumber);
        responseData.firstPress = secs*keyCode;
    end
        
    if responseData.pressed
        break;
    end
    curTime = GetSecs;
end


end

