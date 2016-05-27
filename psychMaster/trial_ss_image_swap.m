function [trialData] = trial_ss_image_swap(expInfo, conditionInfo)


nStim = conditionInfo.nStim;
nTotalCycles = nStim+conditionInfo.nPrePost*2;


timePerStim = expInfo.ifi*conditionInfo.nFramesPerStim;



trialData.validTrial = false;
trialData.abortNow   = false;
flipTimes = nan(nTotalCycles,1);

%Now lets setup response gathering
%KBqueue's are the better way to get responses, quick and accurate but they can be
%fragile on different systems
if expInfo.useKbQueue
    
    keysOfInterest=zeros(1,256);
    keysOfInterest(KbName({'f' 'j' 'ESCAPE'}))=1;
    KbQueueCreate(expInfo.deviceIndex, keysOfInterest);
    KbQueueStart(expInfo.deviceIndex);
    
    KbQueueFlush();
    
end


%Make all the needed textures
for iStim=1:nStim
    allTextures(iStim)=Screen('makeTexture', expInfo.curWindow,conditionInfo.imageMatrix(:,:,iStim));
end
Screen('Flip', expInfo.curWindow);
%Make a list of the textures to present on each cycle.
prefix = repmat([1:2],1,conditionInfo.nPrePost);
postfix = repmat([nStim-1 nStim],1,conditionInfo.nPrePost);
textureList = [prefix 1:nStim postfix];



for iCycle = 1:nTotalCycles

    texIdx = textureList(iCycle);
    Screen('DrawTexture', expInfo.curWindow, allTextures(texIdx), [], [], [], 0);

    
    if iCycle == 1,
        flipTimes(iCycle)=Screen('Flip', expInfo.curWindow);
    else
        flipTimes(iCycle)=Screen('Flip', expInfo.curWindow,flipTimes(iCycle-1)+timePerStim);

    end
    
    if isfield(expInfo,'writeMovie') && expInfo.writeMovie
        Screen('AddFrameToMovie', expInfo.curWindow,...
            CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
    end
    
    if expInfo.useKbQueue
        [ trialData.pressed, trialData.firstPress]=KbQueueCheck(expInfo.deviceIndex);
    else
        [ trialData.pressed, secs, keyCode]=KbCheck(expInfo.deviceIndex);
        trialData.firstPress = secs*keyCode;
    end
    
    
    %Pressed too early.  Abort trial and put in some default values in the
    %returned data.
    if trialData.pressed
        %         trialData.pressed = false;
        %         trialData.firstPress = zeros(size(trialData.firstPress));
        flipTimes(iCycle)=Screen('Flip', expInfo.curWindow);
        trialData.flipTimes = flipTimes;
        trialData.validTrial = false;
        return;
        

    end
    
end

flipTimes(iCycle+1)= Screen('Flip', expInfo.curWindow);
trialData.flipTimes = flipTimes;
trialData.validTrial = true;

% Finalize and close movie file, if any:
if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    Screen('FinalizeMovie', movie);
end
curTime = GetSecs;

%Flush any events that happend before the end of the trial
if expInfo.useKbQueue
    KbQueueFlush();
end

trialData.feedbackMsg = '';

%Reset times to be with respect to trial end.
%trialData.firstPress = trialData.firstPress-trialData.flipTimes(end);

end

