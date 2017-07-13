function [trialData] = ssvepGratingReversal(expInfo, conditionInfo)
%ssvepGratingReversal Trial function for rendering a reversing grating
%[trialData] = ssvepGratingReversal(expInfo, conditionInfo)




phase = 0;%The base phase.  TODO: ensure phase at fixation
spatFreqDeg = conditionInfo.spatialFrequencyDeg;
tiltAngle = 0;
contrast = conditionInfo.contrast; %TODO check achievable contast.


%Determine the spatial frequency in cycles per pix from cycles per deg.
%NB: We are displaying on a flat screen so there is distortation of true cycles per degree
%We're goingto use the screen average conversion factor to get close.  
freqCycPerPix = spatFreqDeg /expInfo.pixPerDeg;

sizeDeg = conditionInfo.sizeDeg;
%Calculate the size in CM we should show on the screen. NB: use of 1/2
%to calculate accurate size. 
sizeCm = 2*(tand(sizeDeg/2)*expInfo.viewingDistance);
sizePix = round(expInfo.pixPerCm * sizeCm); %size in pixels for the stimulus.

%Default to square aperture, unless a circle is requested. 
radius = [];
if isfield(conditionInfo,'aperture') && strcmpi(conditionInfo.aperture,'circle'),
    radius = sizePix;
end

%Use of 0.5 so grating goes from -.5 to +.5 a range of 1.
contrastPreMultiplicator = .5; 

%Setup temporal parameters:
[nFramesPerCycle trialData.achievedFreq] = ...
    ssvepFramesGivenFrequency(conditionInfo.temporalFrequency,expInfo.monRefresh);


cycleHalfPeriod = (nFramesPerCycle/2)/expInfo.monRefresh;
prePostDurSecs = conditionInfo.prePostDurSecs; 
totalDuration = 2*prePostDurSecs+conditionInfo.stimDurSecs;

%We need an integer number of cycles:
%totalDuration/cyclePeriod = duration*Freq bc freq = 1/cyclePeriod. 
nCycles = round(totalDuration*trialData.achievedFreq);

%Use a support of the full size of the grating we're drawing;
supportWidth  = sizePix;
supportHeight = sizePix;
%NB: silly "4" is used because the shader modulates the alpha channel as
%well. We want to ensure the alpha channel is >1 so so it gets clamped to a constant 1.
%But we use a premult of .5
[gratingId, gratingRect] = CreateProceduralSineGrating(expInfo.curWindow,...
    supportWidth, supportHeight,[.5 .5 .5 0], radius, contrastPreMultiplicator);

Screen('BlendFunction', expInfo.curWindow,  GL_ONE, GL_ZERO);

dstRect = [0 0 sizePix sizePix]; 
dstRect = CenterRect(dstRect,expInfo.screenRect); %Center the texture in the current window

modulateColor = [];
photoDiodeRect = [0 0 100 100];
nextFlipTime = GetSecs;%Flip now for the first presentiation. 
for iCycle = 1:nCycles,

    %This index counts at 2x the cycle, each cycle has 2 flips so we want
    %odd numbers for the first half cycle and even numbers for the second
    %half
    flipIdx = 2*(iCycle-1)+1; 
    
    Screen('DrawTexture', expInfo.curWindow, gratingId, [], dstRect, tiltAngle, [], 1,...
        modulateColor, [], [], [phase, freqCycPerPix, contrast, 0]);
    Screen('fillrect',expInfo.curWindow,1,photoDiodeRect);
    
    drawFixation(expInfo); %Draw fixation on top of grating
    
    %On the first half of the cycle send the value in triggerInfo.ssvepTagF1.
    ptbCorgiSendTrigger(expInfo,'ssveptag',false);
      
    [trialData.flipTime(flipIdx)] = Screen('flip',expInfo.curWindow,nextFlipTime);
    %The next flip time will be whenever we just flipped + a half period.
    %PTB tries to flip at the soonest time after the requested time.
    %That is flipTime >=requestFlipTime so we subtract a half frame to the
    %requested time 
    nextFlipTime=trialData.flipTime(flipIdx)+cycleHalfPeriod-expInfo.ifi/2;
    
    flipIdx = 2*(iCycle-1)+2;%This index counts at 2x the cycle, each cycle has 2 flips
    %Draw  180 phase shift which is equivalent to reversal
    Screen('DrawTexture', expInfo.curWindow, gratingId, [], dstRect, tiltAngle, [], 1,...
        modulateColor, [], [], [phase-180, freqCycPerPix, contrast, 0]);
    Screen('fillrect',expInfo.curWindow,0,photoDiodeRect);
    
    drawFixation(expInfo);
    
    % clear the trigger on the second half cycle
    ptbCorgiSendTrigger(expInfo,'clear',false);
    [trialData.flipTime(flipIdx)] = Screen('flip',expInfo.curWindow,nextFlipTime);
    nextFlipTime=trialData.flipTime(flipIdx)+cycleHalfPeriod-expInfo.ifi/2;
  
end
%Leave last half cycle on for appropriate duration before displaying gray
%screen
flipIdx = 2*(iCycle-1)+3;
drawFixation(expInfo);
[trialData.flipTime(flipIdx)] = ...
    Screen('flip',expInfo.curWindow,nextFlipTime);
  
%Cleanup the procedural grating texture used for the stimulus. 
Screen('close',gratingId)

%Check if trial flip times are correct.
trialData.validTrial = true;
flipIntervals = diff(trialData.flipTime); %Inter Flip Intervals

%Compare flip intervals to the expected flip differences. If any of them
%are more than a half frame different from expected declare trial invlaid. 
if any( abs(flipIntervals - cycleHalfPeriod) > expInfo.ifi/2 )
    trialData.cycleErrorDetected = true; %We detected at least one cycle with an incorrect time.

end
Screen('BlendFunction', expInfo.curWindow,  GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);





  