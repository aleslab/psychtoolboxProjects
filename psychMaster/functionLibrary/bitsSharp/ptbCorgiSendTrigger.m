function [ timeSent ] = ptbCorgiSendTrigger( expInfo,command,sendNow,varargin )
%UNTITLED2 Summary of this function goes here
%function [ output_args ] = ptbCorgiSendTrigger( expInfo,trigger,sendNow,varargin )
%   Detailed explanation goes here


%If triggers aren't enables just silently return;
if ~expInfo.enableTriggers
    return;
end

if nargin<2
    error('Error using ptbCorgiSendTrigger');
    return;
end

persistent toggleBitState; %Use a persistent variable to implement a toggle bit.

highTime = 20; % time to be high in the beginning of the frame 
lowTime = 248-highTime; % followed by x msec low (enough to fill the rest of the frame high + low = 24.8 ms)

maskNone = 2^11-1; %Use all bits. 
maskToggle = bitand( maskNone,bitcmp(expInfo.triggerInfo.toggleBit,'uint16'));

mask = maskToggle; %Default mask the toggle, that way other triggers don't set it. 
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
        triggerValue = varargin{1};
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


pulseDef = [repmat(triggerValue,highTime,1);repmat(0,lowTime,1)]';
BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, mask, pulseDef, 0);


%if we want to send the trigger now we need to use 2 frames: 1 to send the
%DIO state and one to clear it. 
if sendNow
timeSent    = Screen('Flip', expInfo.curWindow);
timeCleared = Screen('Flip', expInfo.curWindow);
end


end

