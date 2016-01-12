function [expInfo] = moveLineDefaultSettings(expInfo)

expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
%Let's use kbQueue's because they have high performance.
%screenInfo.useKbQueue = true;
expInfo.useFullScreen = true;
expInfo.instructions = 'Which one moved slower?\nPress any key to begin';
