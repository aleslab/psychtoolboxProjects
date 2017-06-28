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


switch lower(varagin{1})
    
    case 'startRecording'
        
        %SetupPulse
        triggerValue = expInfo.triggerInfo.startRecording;
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, 2^12-1, pulseDef, 0);
        Screen('Flip', expInfo.curWindow);
        Screen('Flip', expInfo.curWindow);

        disp('sending startRecording')
        
    case 'conditionNumber'        
        triggerValue = varargin{2};
        pulseDef = [repmat(triggerValue,highTime,1);repmat(bin2dec('00000000000'),lowTime,1)]';
        BitsPlusPlus('DIOCommand', expInfo.curWindow, 1, 2^12-1, pulseDef, 0);
        Screen('Flip', expInfo.curWindow);
        Screen('Flip', expInfo.curWindow);
end


end

