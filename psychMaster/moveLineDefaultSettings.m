function [expInfo] = moveLineDefaultSettings(expInfo)

expInfo.stereoMode = 4; %0 is monocular, 4 is split screen, 8 is anaglyph
expInfo.viewingDistance = 92; %viewing distance including distance between mirrors and a cm to the eyes is 92cm
expInfo.giveFeedback = false;
%expInfo.useFullScreen = true;
expInfo.instructions = 'Which one moved\nfaster?\nPress any key\nto begin';
expInfo.pauseInfo = 'Paused\nPress any key to\ncontinue';
