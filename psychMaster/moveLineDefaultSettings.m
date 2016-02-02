function [expInfo] = moveLineDefaultSettings(expInfo)

expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
expInfo.giveFeedback = false;
%expInfo.useFullScreen = true;
expInfo.instructions = 'Which one moved\nfaster?\nPress any key\nto begin';
expInfo.pauseInfo = 'Paused\nPress any key to\ncontinue';
