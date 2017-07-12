function [ triggerInfo ] = ptbCorgiTriggerDefault( expInfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Only enabled for bits sharp settings. 
if ~expInfo.useBitsSharp
    warning('ptbCorgi:triggerDefault:noOutput','Triggers only implemented for Bits Sharp Currently, triggers disabled')
    triggerInfo = [];
    return;
end

%Setup pulse time;
triggerInfo.pulseDuration  = 24.8; %Pulse duration in milliseconds, 
%24.8 ms is max for bits#, If a duration longer than the ifi is specificed
%the trigger stays in the state until the next trigger update is used. 

%Define bit values for messages
triggerInfo.startRecording = 2^8;
triggerInfo.startTrial     = 64;
triggerInfo.endTrial     = 65;
triggerInfo.ssvepTagF1     = 1;
triggerInfo.ssvepTagF2     = 2;
triggerInfo.ssvepOddstep   = 4;
triggerInfo.toggleBit      = 2^9;
triggerInfo.messageBitMask    = 2^8-1; %Bits to enable for use as arbitrary messages
triggerInfo.conditionNumberRange = [ 101 165];


%Allow user specified values to overwrite defaults.
if isfield(expInfo,'triggerInfo') && ~isempty(expInfo.triggerInfo)
    triggerInfo = updateStruct(triggerInfo,expinfo.triggerInfo);
end

end

