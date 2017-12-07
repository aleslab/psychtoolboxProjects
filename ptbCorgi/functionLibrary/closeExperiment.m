function closeExperiment()
% closeExperiment Restores settings and closes screen
%[] = closeExperiment()
%
%This function is called when sessions are finished to restore settings and
%close Screen windows/textures. 

Priority(0); %Restore priority settings
RestoreCluts; %Restore gamma table
Screen('CloseAll'); %close open windows/textures
ListenChar(0); %Show Keypresses
ShowCursor(); %Show cursor
