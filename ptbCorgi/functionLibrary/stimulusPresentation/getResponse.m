function [ responseData ] = getResponse(expInfo,responseDuration)
%getResponse - Gets a response with a specified response time window.
%   [ responseData ] = getResponse(expInfo,responseDuration)
%   This is a convenience function and wrapper for both KbCheck and KbQueueCheck to unify the returned
%   data and allow either to be used interchangably. 
%
%   NOTE!  KbQueue's record and store data in the background while KbCheck
%   checks the current state.  If you want to collect keypresses AFTER the
%   call to getResponse flush the KbQueue before calling. E.g.:
%   KbQueueFlush();
%
%   responseData has fields:
%
%   pressed
%   firstPress

startTime = GetSecs;

%Now lets setup response gathering
%KBqueue's are the better way to get responses, quick and accurate but they can be
%fragile on different systems
if expInfo.useKbQueue
    
    %keysOfInterest=zeros(1,256);
    %keysOfInterest(KbName({'f' 'j' 'ESCAPE'}))=1;
%     keysOfInterest=ones(1,256);
%     KbQueueCreate(expInfo.inputDeviceNumber, keysOfInterest);
%     KbQueueStart(expInfo.inputDeviceNumber);    
    %Flush any events that happend before calling this function
    %KbQueueFlush();
    
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
    
    %Now, if RTBox enabled check that and merge it use keyboard test. 
    if expInfo.enableBitsRTBox
        
        [time, event, boxtime] = BitsSharpPsychRTBox('GetSecs', expInfo.RTBoxHandle);
        
        %Store RTBox data
        responseData.RTBoxGetSecsTime = time;
        responseData.RTBoxEvent = event;
        responseData.RTBoxBoxTime = boxtime;
        
        
        %Now merge with keyboard data.   
        if ~isempty(time)

            %Now check if the RTBOX events map to valid key names
            validNames = KbName('KeyNames');
            [c,ia,ib] = intersect(event,validNames);
            validEvent = event(ia);
            validTime = time(ia);
            
            %find the firstpress
            [c,ia,ic]=unique(validEvent,'first');
            firstPressEvent = validEvent(ia);
            firstPressTime  = validTime(ia);
            
            kbIdx = KbName(firstPressEvent);
            responseData.pressed = true;
            responseData.firstPress(kbIdx) = firstPressTime;
                                
                        
            
        end
        
        
       
    end
    
        
    if responseData.pressed
        break;
    end
    curTime = GetSecs;
end


end

