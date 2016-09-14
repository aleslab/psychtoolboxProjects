function [trialData] = serial_gabor_trial(expInfo, conditionInfo)

totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration;
nFrames = round(totalDuration / expInfo.ifi);
nPreStimFrames=round(conditionInfo.preStimDuration/expInfo.ifi);
stimStartFrame = nPreStimFrames+1;

trialData.actualDuration = nFrames*expInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
conditionInfo.stimStartTime = GetSecs; %Get current time to start the clock
flipTimes = nan(nFrames,1);
trialData.mousePos = nan(nFrames,2);
trialData.respOri  = nan(nFrames,1);
trialData.stimOri  = nan(nFrames,1);

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

%parameters for gabor

radiusPix = expInfo.ppd*conditionInfo.stimRadiusDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = expInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
cyclesPerSigma = conditionInfo.freq;    %cycles per standaard devaion
contrast = conditionInfo.contrast;   % contrast 
phase = 90;      %phase of gabor
destRect = [ expInfo.center-radiusPix-1 expInfo.center+radiusPix  ];

orientationSigma=conditionInfo.orientationSigma;

%initAngularVelocity = 0;
%F = [1 0;0 1;];
    
orient = 360*(rand);

lineWidth = 4;
lineLength = expInfo.ppd*.5;
lineColor = [ 0 1 0 1];
initLineOri = orient; 
%Rotation matrix; 
rotMtx = [cosd(initLineOri) -sind(initLineOri);...
          sind(initLineOri) cosd(initLineOri)];
initXy = [0 0; lineLength -lineLength];
xy = rotMtx'*initXy; 

%[minSmoothLineWidth, maxSmoothLineWidth, minAliasedLineWidth, maxAliasedLineWidth] = 

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
% Only video, no sound:
% We raise video quality to 50% for decent looking movies. See
% comments in if-branch for more details about codec settings.
movie = Screen('CreateMovie', expInfo.curWindow, 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
end
% 



if isfield(expInfo,'enablePowermate') 
    if expInfo.enablePowermate
        options.secs=0.0001;
        err=PsychHID('ReceiveReports',expInfo.powermateId,options);
    end
end

totalShift = 0;
[xStart,yStart] = GetMouse(expInfo.curWindow);
y = 0;
lastT = GetSecs;
allT = [];
allY = [];

%flip to screen

screen ('Flip', window);
%for iFrame = 1:nFrames

   %  if expInfo.enablePowermate
       %  err=PsychHID('ReceiveReports',expInfo.powermateId,options);
    % end

    if iFrame>=stimStartFrame
    orient = orient+orientationSigma*randn(); %orient of gabor
    %end
    
    %creates a gabor texture. this has to be in the loop beacuse we want to
    %create a new gabor on every frame we present.
   % t1 = GetSecs;
    my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
    my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
    my_noise = max(min(my_noise,.25),-.25);
    %convert it to a texture 'tex'
    tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);
%     t2 = GetSecs;
%     
%     1000*(t2-t1)
    % stimRect = calculateStimSize(expInfo,conditionInfo);
    % Screen('fillOval', expInfo.curWindow, [60 0 0 180], stimRect);
    Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);
    Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center);

    % Overdraw the rectangular noise image with our special
    % aperture image. The noise image will shine through in areas
    % of the aperture image where its alpha value is zero (i.e.
    % transparent):
    %Screen('DrawTexture', win, aperture, [], dstRect(i,:), [], 0);
    
    
    
     if expInfo.enablePowermate
         Screen('DrawingFinished',expInfo.curWindow,expInfo.dontclear);
         err=PsychHID('ReceiveReports',expInfo.powermateId,options);
     end
    
    flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
    
    if isfield(expInfo,'writeMovie') && expInfo.writeMovie
        Screen('AddFrameToMovie', expInfo.curWindow,...
            CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
    end
    
    if expInfo.enablePowermate
        err=PsychHID('ReceiveReports',expInfo.powermateId,options);
        r=PsychHID('GiveMeReports',expInfo.powermateId);
        if ~isempty(r)
            lastY = y(end);
            y =[cat(1,r(:).report)];
            y = typecast(uint8(y(:,2)),'int8');
            y = double(y);
            y = [lastY; y];
            t = [ 1000*([ lastT r(:).time]-r(1).time) ];
            lastT = r(end).time;
            
            report(iFrame).r = r;
            
            thisShift = .5*trapz(t,y);
            totalShift= totalShift-thisShift;            
        end
        y = 0;
        lastT = GetSecs;
        
        trialData.respOri(iFrame) =  initLineOri+totalShift;
    else
        [x,y] = GetMouse(expInfo.curWindow);
        trialData.mousePos(iFrame,1) = x-xStart;
        trialData.mousePos(iFrame,2) = y-yStart;
        trialData.respOri(iFrame) = initLineOri+.5*(x-xStart);
    end
    
    trialData.stimOri(iFrame) = orient;
    %Rotation matrix; 
    rotMtx = [cosd(trialData.respOri(iFrame)) -sind(trialData.respOri(iFrame));...
          sind(trialData.respOri(iFrame)) cosd(trialData.respOri(iFrame))];
    xy = rotMtx'*initXy;
    
    if expInfo.enablePowermate
        err=PsychHID('ReceiveReports',expInfo.powermateId,options);
    end
    %release the texture after we flip because we will redraw again in this
    %loop.
    Screen('Close', tex);
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
        flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
        trialData.flipTimes = flipTimes;
        trialData.validTrial = false;
        return;
        

    end
    
end

flipTimes(iFrame+1)= Screen('Flip', expInfo.curWindow);
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

score = sum( .001*max(8100-(trialData.respOri(stimStartFrame:end)-trialData.stimOri(stimStartFrame:end)).^2,0));
trialData.feedbackMsg = ['Score: ' num2str(round(score))];


%Reset times to be with respect to trial end.
%trialData.firstPress = trialData.firstPress-trialData.flipTimes(end);

end

