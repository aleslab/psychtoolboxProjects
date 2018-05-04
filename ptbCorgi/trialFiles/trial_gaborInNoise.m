function [trialData] = trial_gaborInNoise(expInfo, conditionInfo)
%gaborInNoiseTrial Function to do a basic gabor in noise
%[trialData] = gaborInNoiseTrial(expInfo, conditionInfo)
%
%This function shows a gabor in noise.
%
%The following fields from conditionInfo set display options:
%
% preStimDurationMin, [.5] - Minimum time before next stimulus
% preStimDurationMu, - [.5] prestim duration is drawn from exponential
%                        distrubution with this mu parameter. Average
%                        preStim duration is the minimum + mu.
% stimDuration, [.1] Stimulus duration in seconds
% postStimMaskDuration, [.5] mask duration in seconds. 
% gaborCenterX - [0] 'Horizontal location of gabor in degrees
% gaborCenterY - [0] Vertical location of gabor in degrees
% gaborPhase   - [90] phase of gabor
% gaborOrientation - [0] Orientation of gabor in degrees (0 vertical, 90 horizontal)
% gaborContrast - [.5] Contrast of gabor
% gaborSigma - [1] Standard deviation of gaussian envelope 
% gaborFreq - [.25] Sine wave frequency in cycles/deg
% stimSizeDeg - [8] Size of
% noiseSigma' - [.15] standard deviation of the luminance values for the noise mask
% fixationDuringStimulus - [expInfo.fixationInfo] Fixation to show during stimulus
% fixationPostStimulus - [expInfo.fixationInfo] Fixation to show after stimulus



trialData.validTrial = true;
trialData.abortNow   = false;


% %Now lets setup response gathering
% KBqueue's are the better way to get responses, quick and accurate but they can be
% fragile on different systems
if expInfo.useKbQueue
    
    keysOfInterest=zeros(1,256);
    keysOfInterest(KbName({'f' 'j' 'ESCAPE'}))=1;
    KbQueueCreate(expInfo.deviceIndex, keysOfInterest);
    KbQueueStart(expInfo.deviceIndex);
    
    KbQueueFlush();
end

%setup default options for the stimulus:
defaultStimValues = {
    'preStimDurationMin',.5,...
    'preStimDurationMu',.5,...
    'stimDuration',.1,...
    'postStimMaskDuration',.5,...
    'gaborCenterX',0,...
    'gaborCenterY',0,...
    'gaborSigma',1,...
    'gaborFreq',.25,...
    'gaborPhase',90,...
    'gaborOrientation',0,...
    'gaborContrast',.5,...
    'stimSizeDeg', 8,...
    'noiseSigma',.15,...
    'fixationPreStimulus', expInfo.fixationInfo,...
    'fixationDuringStimulus', expInfo.fixationInfo,...
    'fixationPostStimulus',expInfo.fixationInfo,...
};

%If any fields are missing or empty from conditionInfo set them to their default value
conditionInfo = validateFields(conditionInfo,defaultStimValues);

drawFixation(expInfo,conditionInfo.fixationPreStimulus);
trialData.stimStartTime = Screen('Flip',expInfo.curWindow);

preStimDuration = conditionInfo.preStimDurationMin+exprnd(conditionInfo.preStimDurationMu)
requestedStimStartTime = trialData.stimStartTime + preStimDuration;

%Change defrees to pixels.
gaborCenterXPix = expInfo.ppd*conditionInfo.gaborCenterX;
gaborCenterYPix = expInfo.ppd*conditionInfo.gaborCenterY;

%Vector form for some options. 
gaborCenterPix = [gaborCenterXPix gaborCenterYPix];



% parameters for gabor

stimSizePix = expInfo.ppd*conditionInfo.stimSizeDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = expInfo.ppd*conditionInfo.gaborSigma;  % standard deviation in degrees iinto pixels
%createGabor() uses a silly cycles per sigma freqeuncy value
% dimensional analysis:
% cycles/deg * deg/sigma = cycles/sigma
cyclesPerSigma = conditionInfo.gaborFreq * conditionInfo.stimSizeDeg;   
contrast = conditionInfo.gaborContrast;   % contrast
phase = conditionInfo.gaborPhase;  %phase of gabor
gaborDestRect = [ expInfo.center-stimSizePix-1 expInfo.center+stimSizePix  ];

noiseDestRect = [ expInfo.center-stimSizePix-1 expInfo.center+stimSizePix  ];

orient = conditionInfo.gaborOrientation;


if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    movie = Screen('CreateMovie', expInfo.curWindow, 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
end




%Create Gabor
my_gabor = createGaborCorrectScale(stimSizePix, sigmaPix, cyclesPerSigma, contrast, phase, orient,gaborCenterXPix,gaborCenterYPix);
my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
%my_noise = max(min(my_noise,.5),-.25);
combinedStim = my_gabor+my_noise;
combinedStim = min(1,max(0,combinedStim)); %Clamp values between 0 and 1.
%convert it to a texture 'tex'
tex=Screen('makeTexture', expInfo.curWindow, combinedStim);
% gabTex=Screen('makeTexture', expInfo.curWindow, my_gabor);
% noiseTex = Screen('makeTexture', expInfo.curWindow, my_noise);



%draw the Gabor
%Screen('DrawTexture', expInfo.curWindow, noiseTex, [], noiseDestRect, [], 0,[]);
%Screen('DrawTexture', expInfo.curWindow, gabTex, [], gaborDestRect, [], 0,[]);

Screen('DrawTexture', expInfo.curWindow, tex, [], noiseDestRect, [], 0,[]);

drawFixation(expInfo,conditionInfo.fixationDuringStimulus);
stimStartTime= Screen('Flip',expInfo.curWindow,requestedStimStartTime);
requestedStimEndTime=stimStartTime + conditionInfo.stimDuration;


%Make it empty
maskTex = [];
%If we want to show a postStim
if conditionInfo.postStimMaskDuration >0

    %draw the mask
    noiseMask = conditionInfo.noiseSigma.*randn(size(my_gabor));
    maskTex=Screen('makeTexture', expInfo.curWindow, noiseMask+0.5);
    Screen('DrawTexture', expInfo.curWindow, maskTex, [], noiseDestRect, [], 0);
      drawFixation(expInfo,conditionInfo.fixationPostStimulus);
    actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);
    
    %calculate mask offset time
    requestedMaskEndTime = actualStimEndTime + conditionInfo.postStimMaskDuration;
    drawFixation(expInfo,conditionInfo.fixationPostStimulus);
    actualMaskEndTime = Screen('Flip', expInfo.curWindow, requestedMaskEndTime);
    trialData.maskEndTime   = actualMaskEndTime;
else
    
    drawFixation(expInfo,conditionInfo.fixationPostStimulus);
    actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);
end




trialData.stimStartTime = stimStartTime;
trialData.stimEndTime   = actualStimEndTime;

% trialData.fixEndTime    = actualFixEndTime;

trialData.validTrial = true;
trialData.stimOri = wrapTo180(orient); %wrapTo180 makes angle go from[-180 180];

%clean up textures:
if ~isempty(maskTex)
    Screen('Close',maskTex);
end

Screen('Close',tex);



