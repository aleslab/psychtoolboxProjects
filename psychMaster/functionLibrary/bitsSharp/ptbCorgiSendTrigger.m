function [ output_args ] = ptbCorgiSendTrigger( expInfo,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%If triggers aren't enables just silently return;
if ~expInfo.enableTriggers
    return;
end

if nargin<2
    error('Error using ptbCorgiSendTrigger');
    return;
end

highTime = 20; % time to be high in the beginning of the frame 
lowTime = 248-highTime; % followed by x msec low (enough to fill the rest of the frame high + low = 24.8 ms)

switch lower(varargin{1})
    
    case 'startrecording'
        
        %SetupPulse
        triggerValue = expInfo.triggerInfo.startRecording;
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, 2^12-1, pulseDef, 0);
        Screen('Flip', expInfo.curWindow);
        Screen('Flip', expInfo.curWindow);

        disp(['sending startRecording trigger value: ' num2str(triggerValue)]);
        
    case 'conditionnumber'        
        triggerValue = varargin{2};
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, 2^12-1, pulseDef, 0);
        Screen('Flip', expInfo.curWindow);
        Screen('Flip', expInfo.curWindow);
        disp(['sending conditionNumber trigger value: ' num2str(triggerValue)]);

end


end

