function [ timeSent ] = ptbCorgiSendTrigger( expInfo,command,sendNow,varargin )
%ptbCorgiSendTrigger Handles sending various triggers
%[ [timeSent] ] = ptbCorgiSendTrigger( expInfo,trigger,sendNow,varargin )
%   Detailed explanation goes here
%
%
%
%Commands:

timeSent = NaN; %If we haven't sent a trigger init as NaN;

%If triggers aren't enables just silently return;
if ~expInfo.enableTriggers
    return;
end

%If missing triggerInfo, rather than erroring out print a warning and keep
%going. 
if ~isfield(expInfo,'triggerInfo')
   warning('ptbCorgi:sendTrigger:missingInfo','triggerInfo field missing, cannot send trigger!');
   return;
end

%If wrong inputs error out.  
if nargin<2
    error('Error using ptbCorgiSendTrigger, see help ptbCorgiSendTrigger');
    return;
end

persistent toggleBitState; %Use a persistent variable to implement a toggle bit.


%Bits sharp trigger times are in 100 MICROsecond chunks.  
%I.e. 24.8 ms -> 248 100 microsecond. 
%Length of data block is 248 so make sure we don't overflow with a min(). 
highTime = min(248,round(expInfo.triggerInfo.pulseDuration*10)); % time to be high in the beginning of the frame 
lowTime = 248-highTime; % followed by x msec low (enough to fill the rest of the frame high + low = 24.8 ms)

maskNone = 2^11-1; %Use all bits. 
maskToggle = bitand( maskNone,bitcmp(expInfo.triggerInfo.toggleBit,'uint16'));

mask = maskToggle; %Default mask the toggle, that way other triggers don't set it. 
yPos = 2;%Put triggers on the 2nd line. 
switch lower(command)
    
    case {'clear','alllow','init','initialize'}
        
        triggerValue = 0;
        toggleBitState = 0;        
        mask = maskNone;
        disp(['Clearing all triggers to 0']);
    case 'startrecording'
        
        triggerValue = expInfo.triggerInfo.startRecording;        
        disp(['sending startRecording trigger value: ' num2str(triggerValue)]);
        
    case 'conditionnumber' %Currently just sends the raw bits, but may change in future      
        triggerValue = varargin{1}+expInfo.triggerInfo.conditionNumberRange(1)-1; %Subtract one so the trigger range is inclusive
        if triggerValue > expInfo.triggerInfo.conditionNumberRange(2)
            warning('ptbCorgi:sendTrigger:condNumMaxExceeded','Sending condition number trigger value over range, still sending but check yourself');
        end
        
        disp(['sending conditionNumber trigger value: ' num2str(triggerValue)]);

    case 'raw'         
        triggerValue = varargin{1};
        disp(['sending raw trigger value: ' num2str(triggerValue)]);
        
    case 'togglebit'        
        if isempty(toggleBitState)
            toggleBitState = 0;
            warning('togglebit state undefined setting to 1');
        end
        toggleBitState = ~toggleBitState;
        triggerValue = expInfo.triggerInfo.toggleBit*(toggleBitState);
        mask = bitcmp(maskToggle,'uint16'); %Mask everything but the toggle bit.
        highTime=248;
        lowTime = 0;

end


pulseDef = [repmat(triggerValue,highTime,1);zeros(lowTime,1)]';
BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, mask, pulseDef, 0,0, yPos);


%if we want to send the trigger now we need to use 2 frames: 1 to send the
%DIO state and one to clear it. 
if sendNow
drawFixation(expInfo);
timeSent    = Screen('Flip', expInfo.curWindow);
pulseDef = [repmat(0,highTime,1);zeros(lowTime,1)]';
BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, mask, pulseDef, 0,0, yPos);
drawFixation(expInfo);
timeCleared = Screen('Flip', expInfo.curWindow);
trigDur=(timeCleared -timeSent)*1000
end


end

