function [trialData] = rotating_gabor_trial(screenInfo, conditionInfo)

totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration+conditionInfo.postStimDuration;
nFrames = round(totalDuration / screenInfo.ifi);
trialData.actualDuration = nFrames*screenInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
conditionInfo.stimStartTime = GetSecs; %Get current time to start the clock
flipTimes = nan(nFrames,1);


%Now lets setup response gathering
%KBqueue's are the better way to get responses, quick and accurate but they can be
%fragile on different systems
if screenInfo.useKbQueue
    
    keysOfInterest=zeros(1,256);
    keysOfInterest(KbName({'f' 'j' 'ESCAPE'}))=1;
    KbQueueCreate(screenInfo.deviceIndex, keysOfInterest);
    KbQueueStart(screenInfo.deviceIndex);
    
    KbQueueFlush();
    
end

%parameters for gabor

radiusPix = 256;screenInfo.ppd*conditionInfo.stimRadiusDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = screenInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
cyclesPerSigma = 2;    %cycles per standaard devaion
contrast = 0.45;   % contrast 
phase = 0.25;      %phase of gabor
      


orientationSigma=conditionInfo.orientationSigma;
orientationVelocity = .1;
    
orient = 0;
for iFrame = 1:nFrames

    %orient = orient+orientationSigma*randn(); %orient of gabor
    orientationVelocity = orientationVelocity+orientationSigma*randn();
    
    orient = orient+orientationVelocity.^2; %orient of gabor
    
    
    %creates a gabor texture. this has to be in the loop beacuse we want to
    %create a new gabor on every frame we present.
    my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
    my_noise= 0.4*randn(size(my_gabor));
    %convert it to a texture 'tex'
    tex=Screen('makeTexture', screenInfo.curWindow, my_gabor+my_noise);
    
    thisTime =  GetSecs - conditionInfo.stimStartTime-conditionInfo.preStimDuration;
    %How long has it been since last draw?
    
%     flipTimes(iFrame)=Screen('Flip', screenInfo.curWindow);
%     %release the texture after we flip because we will redraw again in this
%     %loop.
%     Screen('Close', tex);
%     
    
    
    %relcalculate time to account for pre and post stim
    %
    conditionInfo.stimTime = min(max(thisTime,0),conditionInfo.stimDuration);
    
    % stimRect = calculateStimSize(screenInfo,conditionInfo);
    % Screen('fillOval', screenInfo.curWindow, [60 0 0 180], stimRect);
    Screen('DrawTexture', screenInfo.curWindow, tex, [], screenInfo.screenRect, [], 0);
    
    % Overdraw the rectangular noise image with our special
    % aperture image. The noise image will shine through in areas
    % of the aperture image where its alpha value is zero (i.e.
    % transparent):
    %Screen('DrawTexture', win, aperture, [], dstRect(i,:), [], 0);
    
    
    Screen('DrawingFinished',screenInfo.curWindow,screenInfo.dontclear);
    
    flipTimes(iFrame)=Screen('Flip', screenInfo.curWindow);
    
    %release the texture after we flip because we will redraw again in this
    %loop.
    Screen('Close', tex);
    if screenInfo.useKbQueue
        [ trialData.pressed, trialData.firstPress]=KbQueueCheck(screenInfo.deviceIndex);
    else
        [ trialData.pressed, secs, keyCode]=KbCheck(screenInfo.deviceIndex);
        trialData.firstPress = secs*keyCode;
    end
    
    
    %Pressed too early.  Abort trial and put in some default values in the
    %returned data.
    if trialData.pressed
        %         trialData.pressed = false;
        %         trialData.firstPress = zeros(size(trialData.firstPress));
        flipTimes(iFrame)=Screen('Flip', screenInfo.curWindow);
        trialData.flipTimes = flipTimes;
        trialData.validTrial = false;
        return;
        

    end
    
end

flipTimes(iFrame+1)= Screen('Flip', screenInfo.curWindow);
trialData.flipTimes = flipTimes;

curTime = GetSecs;

%Flush any events that happend before the end of the trial
if screenInfo.useKbQueue
    KbQueueFlush();
end

%Now fire a busy loop to process any keypress durring the response window.
while curTime<flipTimes(end)+conditionInfo.responseDuration
    
    
    if screenInfo.useKbQueue
        [ trialData.pressed, trialData.firstPress]=KbQueueCheck(screenInfo.deviceIndex);
    else
        [ trialData.pressed, secs, keyCode]=KbCheck(screenInfo.deviceIndex);
        trialData.firstPress = secs*keyCode;
    end
    
    
    if trialData.pressed
        break;
    end
    curTime = GetSecs;
end

if trialData.firstPress(KbName('ESCAPE'))
    %pressed escape lets abort experiment;
    trialData.validTrial = false;
    trialData.abortNow = true;
    
elseif trialData.firstPress(KbName('f'))
    trialData.response = 'f';
    trialData.responseTime = ...
        trialData.firstPress(KbName('f'))-trialData.flipTimes(end);
    trialData.validTrial = true;
    
    if conditionInfo.targetAmp > 0
        feedbackMsg = ['Hit\n\nWin ' num2str(screenInfo.payoff(1)) ' points'];
        
        trialData.correctResponse = true;
        
    else
        feedbackMsg = ['False Alarm\n\nLose ' num2str(abs(screenInfo.payoff(4))) ' points'];
        
        trialData.correctResponse = false;
    end
    
elseif trialData.firstPress(KbName('j'))
    trialData.response = 'j';
    trialData.responseTime = ...
        trialData.firstPress(KbName('j'))-trialData.flipTimes(end);
    trialData.validTrial = true;
    
    if conditionInfo.targetAmp > 0
        feedbackMsg = ['Miss\n\nLose ' num2str(abs(screenInfo.payoff(3))) ' points'];
        trialData.correctResponse = false;
        
    else
        feedbackMsg = ['Correct Reject\n\nWin ' num2str(screenInfo.payoff(2)) ' points'];
        trialData.correctResponse = true;
    end
    
else %Wait a minute this isn't a valid response
    
    feedbackMsg  = ['Invalid Response'];
    trialData.validTrial = false;
    
end

trialData.feedbackMsg = feedbackMsg;

%Reset times to be with respect to trial end.
%trialData.firstPress = trialData.firstPress-trialData.flipTimes(end);

end



function stimRect = calculateStimSize(screenInfo,conditionInfo)


%calculate object distance given starting size and how long the stimulus has been on;
objectDistance = screenInfo.subjectDist-conditionInfo.stimTime*conditionInfo.visualVelocity;

%given the object is simulated to have moved to objectDistance calculate
%the pixel size of the stimulus
stimRadiusDegrees = atand(conditionInfo.stimRadiusCm/objectDistance);
stimRadiusPixels  = round(screenInfo.ppd*stimRadiusDegrees);


stimLeft    = screenInfo.center(1) - stimRadiusPixels;
stimTop     = screenInfo.center(2) - stimRadiusPixels;
stimRight   = screenInfo.center(1) + stimRadiusPixels;
stimBottom  = screenInfo.center(2) + stimRadiusPixels;

stimRect = [stimLeft stimTop stimRight stimBottom];
end
