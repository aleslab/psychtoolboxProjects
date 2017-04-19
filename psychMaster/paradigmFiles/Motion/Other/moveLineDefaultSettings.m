function [expInfo] = moveLineDefaultSettings(expInfo)

expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
expInfo.viewingDistance = 97; %viewing distance including distance between mirrors and a cm to the eyes/chin rest is 97cm
%expInfo.useFullScreen = true;
expInfo.instructions = 'Which one \nchanged speed?\nPress any key\nto begin';
expInfo.pauseInfo = 'Paused\nPress any keys\nto continue';
