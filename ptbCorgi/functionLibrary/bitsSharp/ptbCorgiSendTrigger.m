function [ timeSent ] = ptbCorgiSendTrigger( expInfo,command,sendNow,varargin )
%ptbCorgiSendTrigger Handles sending various triggers
%[ [timeSent] ] = ptbCorgiSendTrigger( expInfo,command,sendNow, [command specific inputs] )
%  
%This functions implements a convient wrapper for sending triggers. It
%silently returns if triggers aren't enabled allowing it to be including in
%code for use in paradigms when triggers are active and not without errors.
%
%Triggers depend on devices used. Currently the Bits# device from CRS is
%implemented.  
%With the bitssharp triggers are written to the frame and sent to the bits
%sharp on a flip. The triggers remain active while the flipped frame
%remains on the screen. The timing sequence for a bits# is that the trigger
%is genereted the frame AFTER recieving the instruction. So expect a 1
%frame delay. The bits# will continue to generate the trigger as long as
%the frame stays the same.  The present pulse duration is set to 24.8 ms
%that way for framerates above 40 hz the trigger will stay in whatever
%state was set instead of making a pulse train. If the sendNow argument is
%false the state will be set on the next call to Screen('flip'), and
%cleared on the following call to Screen('flip').
%
%Make sure you don't overwrite the value of the pixels in the 2nd line with
%subsequent drawing commands. 
%
%Inputs:
%
% expInfo - The experiment info structure. The following fields are used:
%         expInfo.useBitsSharp = [false] If true use bitsSharp
%         expInfo.enableTriggers = [false] if true enable triggering, if
%                                  false return silently.
%
% command - A string chosen from the available commands listed below
% sendNow - a boolean, if set to 'true' the dio command is sent now via
% executing 2 consecutive Screen('flip'). The first sets the command the
% second clears the command. So the trigger is only sent for 1 frame. NOTE!
% this also clears the screen so only the fixation remains. 
% The remaining arguments are used by the various commands, see below. 
%  Commands:
%  The following are acceptable commands. Values with {} are synonymous. 
%
%{'clear','alllow','init','initialize'}
%         
% Any of these commands Sets all trigger out values to 0, sets the state of
% the toggle bit to 0.
%
%'startrecording'
% Sends the start recording trigger value. 
%         
%'conditionNumber' 
% Send a value corresponding to the condition number passed in throug.  The triggerInfo
% field conditionNumberRange is used to translate the raw condition number
% (e.g. 1,2,3) into the digital out number range. E.g. if the range is 
% [101 165], the condition numbers on the digital out go from 101 to 165.
% Example:
% ptbCorgiSendTrigger(expInfo,'conditionNumber',true,4)
% will immediately set the Digital out state to 104 for a frame 
% 
%'raw' 
%  Send an arbitrary value. 
% Example:
% ptbCorgiSendTrigger(expInfo,'raw',false,1+2+4)
% will set the first 3 bits to 1 after the next call to Screen('flip')
%
%'togglebit'    
% This is used to set the state of the togglebit. This bit (set in
% triggerInfo.toggleBit) can be set independently of the other bit values.
% The toggle bit is masked out from being modified via the other commands. 
% The state of this bit can either be toggled or set directly. 
% Example:
% ptbCorgiSendTrigger(expInfo,'togglebit',false)       
% toggles the state of the bit on the next call to Screen('flip')
% ptbCorgiSendTrigger(expInfo,'togglebit',false,true)       
% Sets the state of the toggle bit to 1 on the next Screen('flip')
%
% {'tag', 'f1','tagf1','ssvep','ssveptag', 'ssveptagf1'}  
% Any of these will send the value set in triggerInfo.ssvepTagF1
        
    
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
yPos = 2;%Put triggers on the 2nd line, instead of the default 3rd line.  
switch lower(command)
    
    case {'clear','alllow','init','initialize'}
        
        triggerValue = 0;
        toggleBitState = 0;        
        mask = maskNone;
        trigMessage = 'Clearing all triggers to 0';
    case 'startrecording'
        
        triggerValue = expInfo.triggerInfo.startRecording;        
        trigMessage = (['sending startRecording trigger value: ' num2str(triggerValue)]);
        
    case 'starttrial'
        triggerValue = expInfo.triggerInfo.startTrial;        
        trigMessage=sprintf(['sending startTrial trigger value: ' num2str(triggerValue)]);
        
    case 'endtrial'
        triggerValue = expInfo.triggerInfo.startTrial;        
        trigMessage=sprintf(['sending endTrial trigger value: ' num2str(triggerValue)]);
    
    case 'conditionnumber' 
        triggerValue = varargin{1}+expInfo.triggerInfo.conditionNumberRange(1)-1; %Subtract one so the trigger range is inclusive
        if triggerValue > expInfo.triggerInfo.conditionNumberRange(2)
            warning('ptbCorgi:sendTrigger:condNumMaxExceeded','Sending condition number trigger value over range, still sending but check yourself');
        end
        
        trigMessage=sprintf('Sending conditionNumber trigger value: %i',triggerValue);

    case 'raw'         
        triggerValue = varargin{1};
        trigMessage=sprintf('Sending raw trigger value: %i ',triggerValue);
        
    case {'tag', 'f1','tagf1','ssvep','ssveptag', 'ssveptagf1'}                
        
        triggerValue = expInfo.triggerInfo.ssvepTagF1;
        trigMessage=sprintf('Sending SSVEP f1 trigger %i',triggerValue);
        
    case 'togglebit'     
        
        %If given a state for the toggle bit use it. 
        if ~isempty(varargin{1})
            %Set it to the opposite of what is asked because we toggle it
            %below. Yes this is silly and seems intentially obfuscating.
            %I'm just lazy. 
            toggleBitState = ~logical(varargin{1}); 
        end
        
        if isempty(toggleBitState)
            toggleBitState = 0;
            warning('togglebit state undefined setting to 1');
        end
        
        toggleBitState = ~toggleBitState;
        
        triggerValue = expInfo.triggerInfo.toggleBit*(toggleBitState);
        mask = bitcmp(maskToggle,'uint16'); %Mask everything but the toggle bit.
        highTime=248;
        lowTime = 0;
        
        trigMessage=sprintf('Toggling bit to state %',triggerValue);
        
    otherwise
        warning('Command not ''%s'' found. No trigger set',command)
        return;

end


% disp(trigMessage);

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
  
end


end

