function closeExperiment()
% closeExperiment
% closes the screen, returns priority to zero,
% and shows the cursor.

Priority(0);
RestoreCluts;
Screen('CloseAll');
PsychPortAudio('Close');
ListenChar(0);
