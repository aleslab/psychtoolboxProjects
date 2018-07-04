function [trialData] = trial_summerfieldInstructions(expInfo, conditionInfo)

trialData.validTrial = true;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
trialData.stimStartTime = GetSecs; %Get current time to start the clock


% %Now lets setup response gathering
if expInfo.useKbQueue
    
    KbQueueFlush();
end

lineColor = [0 1 0];
lineWidth = 2;
lineLength = expInfo.ppd*3;
initXy = [0 0; lineLength -lineLength];



if strcmpi(conditionInfo.instructionType,'a/~a')
    lineColor = [0 1 0];
    thisOrient = conditionInfo.orientA;
    %Rotation matrix;
    rotMtx = [cosd(thisOrient) -sind(thisOrient);...
        sind(thisOrient) cosd(thisOrient)];
    xy = rotMtx'*initXy;

    Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);
    
    trialData.stimStartTime = Screen('Flip', expInfo.curWindow);
    
elseif strcmpi(conditionInfo.instructionType,'a/b')
    thisOrient = conditionInfo.orientA;
    %Rotation matrix;
    rotMtx = [cosd(thisOrient) -sind(thisOrient);...
        sind(thisOrient) cosd(thisOrient)];
    xy = rotMtx'*initXy;

    
    lineColor = [1 0 0];
    Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);

    thisOrient = conditionInfo.orientA+60;
    %Rotation matrix;
    rotMtx = [cosd(thisOrient) -sind(thisOrient);...
        sind(thisOrient) cosd(thisOrient)];
    xy = rotMtx'*initXy;


    lineColor = [0 0 1];
    Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);
    
    trialData.stimStartTime = Screen('Flip', expInfo.curWindow);
    
end

trialData.stimEndTime=Screen('Flip', expInfo.curWindow,trialData.stimStartTime+3);




