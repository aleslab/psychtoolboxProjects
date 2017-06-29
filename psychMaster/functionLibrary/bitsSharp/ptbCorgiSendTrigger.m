function [ output_args ] = ptbCorgiSendTrigger( expInfo,command,sendNow,varargin )
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

maskNone = 2^12-1;
maskToggle = bitand( maskNone,expInfo.triggerInfo.toggleBit);

switch lower(varargin{1})
    
    case {'clear','alllow','init','initialize'}
        
        triggerValue = 0;
        toggleBitState = 0;
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, maskNone, pulseDef, 0);
        toggleBitState = 0;

        disp(['sending startRecording trigger value: ' num2str(triggerValue)]);
    case 'startrecording'
        
        %SetupPulse
        triggerValue = expInfo.triggerInfo.startRecording;
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, 2^12-1, pulseDef, 0);


        disp(['sending startRecording trigger value: ' num2str(triggerValue)]);
        
    case 'conditionnumber'        
        triggerValue = varargin{2};

        disp(['sending conditionNumber trigger value: ' num2str(triggerValue)]);
        
    case 'togglebit'
        
         
         

end


pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, mask, pulseDef, 0);


%if we 
if sendNow
Screen('Flip', expInfo.curWindow);
Screen('Flip', expInfo.curWindow);
end


end

