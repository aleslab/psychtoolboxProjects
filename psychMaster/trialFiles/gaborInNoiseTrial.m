function [trialData] = gaborInNoiseTrial(expInfo, conditionInfo)
%test edit

trialData.validTrial = true;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
trialData.stimStartTime = GetSecs; %Get current time to start the clock


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



% parameters for gabor

radiusPix = expInfo.ppd*conditionInfo.stimRadiusDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = expInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
cyclesPerSigma = conditionInfo.freq;    %cycles per standaard devaion
contrast = conditionInfo.contrast;   % contrast
phase = 90;      %phase of gabor
destRect = [ expInfo.center-radiusPix-1 expInfo.center+radiusPix  ];

orient = conditionInfo.orientation;



%Some parameters for the response line
lineWidth = 4;
lineLength = expInfo.ppd*3; %Line length in pixels
lineColor = [1];


if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    movie = Screen('CreateMovie', expInfo.curWindow, 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
end




%create a new gabor on every frame we present.
my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
%my_noise = max(min(my_noise,.5),-.25);
%convert it to a texture 'tex'
tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);

%draw the Gabor
Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);
stimStartTime= Screen('Flip',expInfo.curWindow);
requestedStimEndTime=stimStartTime + conditionInfo.stimDuration;
Screen('Close',tex);

%draw the mask
noiseMask = conditionInfo.noiseSigma.*randn(size(my_gabor));
maskTex=Screen('makeTexture', expInfo.curWindow, noiseMask+0.5);
Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);


actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);
Screen('Close',maskTex);

%calculate mask offset time
requestedMaskEndTime = actualStimEndTime + 1;
actualMaskEndTime = Screen('Flip', expInfo.curWindow, requestedMaskEndTime);

%Calculate the fixation offset time
requestedFixEndTime = actualMaskEndTime + 0.25;
actualFixEndTime = Screen('Flip', expInfo.curWindow, requestedFixEndTime);


trialData.stimStartTime = stimStartTime;
trialData.stimEndTime   = actualStimEndTime;
trialData.maskEndTime   = actualMaskEndTime;
trialData.fixEndTime    = actualFixEndTime;

trialData.validTrial = true;
trialData.stimOri = wrapTo180(orient); %wrapTo180 makes angle go from[-180 180];




