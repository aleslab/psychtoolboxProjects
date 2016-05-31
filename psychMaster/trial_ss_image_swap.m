function [trialData] = trial_ss_image_swap(expInfo, conditionInfo)


nPairs= conditionInfo.nPairs;
nStim = nPairs*2; %Number of different stimuli to present.
nTotalImages = conditionInfo.nPairRepeats*(nStim+conditionInfo.nPrePost*2*2);
nTotalCycles = conditionInfo.nPairRepeats*(nPairs+conditionInfo.nPrePost*2);


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

for iPair = 1:nPairs
    for iAB = 1:2,
    allTextures(iPair,iAB)=Screen('makeTexture', expInfo.curWindow,conditionInfo.imageMatrix(:,:,iPair,iAB));
    end
end
Screen('Flip', expInfo.curWindow);

%Make a list of the textures to present on each cycle.
textureList = zeros(1,nTotalCycles);
nPrePostPairs = conditionInfo.nPairRepeats*conditionInfo.nPrePost;
startIdx = nPrePostPairs;
for iPair = 1:nPairs, %Go through each pair of stim
    for iPairRepeat = 1:conditionInfo.nPairRepeats, %repeat the pair this number of times
        thisIdx = startIdx + 2*(iPair-1)+ iPairRepeat
        textureList(thisIdx) = iPair;
    end
end

textureList(1:nPrePostPairs) = 1;
textureList((end-nPrePostPairs+1):end) = nPairs;
            


nTotalCycles

for iCycle = 1:nTotalCycles
    for iAB = 1:2,

    texIdx = textureList(iCycle);
    Screen('DrawTexture', expInfo.curWindow, allTextures(texIdx,iAB), [], [], [], 0);

    
    if iCycle == 1 && iAB == 1,
        flipTimes(iCycle,iAB)=Screen('Flip', expInfo.curWindow);
    else
        flipTimes(iCycle,iAB)=Screen('Flip', expInfo.curWindow,previousFlipTime+timePerStim);   
    end
    
    previousFlipTime = flipTimes(iCycle,iAB);
    
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
        flipTimes(iCycle,iAB)=Screen('Flip', expInfo.curWindow);
        trialData.flipTimes = flipTimes;
        trialData.validTrial = false;
        return;
        

    end
    
    end
end


flipTimes(iCycle+1)= Screen('Flip', expInfo.curWindow,previousFlipTime+timePerStim);
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

