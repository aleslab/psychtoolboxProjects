function [ trialData ] = brokenTrial( expInfo,conditionInfo )
trialData =[];


%Very simple stim just flick a rectangle from black to white:
Screen('fillRect',expInfo.curWindow,0,[300 300 400 400])
drawFixation(expInfo,expInfo.fixationInfo);
Screen('flip',expInfo.curWindow)
WaitSecs(1);

Screen('fillRect',expInfo.curWindow,1,[300 300 400 400])
Screen('flip',expInfo.curWindow)
WaitSecs(1);

%Examples for testing errors:
%Matlab errors don't close the window handle
%Screen() errors can cause the window handle to close
%These have different downstream effects on how you recover. 

%%Matlab error not enough input arguments:
%incompleteLine = sin();

%%Psychtoolbox error causing screen fault:
%Incorrect calling style for 'fillrect':
Screen('fillRect')

end

