function [ triggerInfo ] = ptbCorgiTriggerDefault( expInfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Only enabled for bits sharp settings. 
if ~expInfo.useBitsSharp
    warning('ptbCorgi:triggerDefault:noOutput','Triggers only implemented for Bits Sharp Currently, triggers disabled')
    triggerInfo = [];
    return;
end

%Define bit values for messages
triggerInfo.startRecording = 2^8;
triggerInfo.startTrial     = 1;
triggerInfo.ssvepClock     = 2^9;
triggerInfo.messageBits    = 2^7-1; %Bits to enable for use as arbitrary messages

%Allow user specified values to overwrite defaults.
if isfield(expInfo,'triggerInfo') && ~isempty(expInfo.triggerInfo)
    triggerInfo = updateStruct(triggerInfo,expinfo.triggerInfo);
end

end

