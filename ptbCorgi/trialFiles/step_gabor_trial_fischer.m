function [trialData] = step_gabor_trial_fischer(expInfo, conditionInfo)
%test edit

trialData.validTrial = true;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
trialData.stimStartTime = GetSecs; %Get current time to start the clock

feedbackDur=2;
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

if ~isfield(expInfo,'enableKeyboard')
    expInfo.enableKeyboard = false;
    
end

if ~isfield(conditionInfo,'showFeedbackGabor');
    conditionInfo.showFeedbackGabor=false;
end

if isfield(conditionInfo, 'gaborCenterX');
    gaborCenterXPix = expInfo.ppd*conditionInfo.gaborCenterX;

else
    gaborCenterYPix = 0;
end

%Vector form for some options. 
gaborCenterPix = [gaborCenterXPix gaborCenterYPix];

% parameters for gabor

sigmaPix  = expInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
radiusPix = round(sigmaPix*5);    % stimSize in degrees x pixels per degree.

smoothingSigmaPix = expInfo.ppd*conditionInfo.noiseSmoothSigma;
cyclesPerSigma = conditionInfo.freq;    %cycles per standaard devaion
contrast = conditionInfo.gaborContrast;   % contrast
phase = 0;      %phase of gabor
destRect = [ expInfo.center+gaborCenterPix-radiusPix-1 expInfo.center+gaborCenterPix+radiusPix  ];




%If no update is specified default to brownian.
if ~isfield( conditionInfo, 'updateMethod') || isempty(conditionInfo.updateMethod)
    conditionInfo.updateMethod = 'brownian';
end

persistent orient
if isempty(orient);
    orient=360*rand;
end

switch lower(conditionInfo.updateMethod)
    case 'brownian' %brownian motion updates from last trial
        orient = orient + randn*conditionInfo.orientationSigma;
    case 'uniform' %draws a uniform orientation from 360 degrees
        orient = rand*360;
        
end

% orient=360*rand;
% expInfo.currentTrial.number
currentIndex = mod(expInfo.currentTrial.number,3*conditionInfo.trials_per_step);% current phase of orientation 
if currentIndex==1;
    orient=(orient);
elseif currentIndex==conditionInfo.trials_per_step+1;
    orient=orient+conditionInfo.step_size_deg;
elseif currentIndex==conditionInfo.trials_per_step*2+1
    orient=orient-conditionInfo.step_size_deg;
else
    orient = orient;
    
end

    

%Some parameters for the response line
[minSmoothLineWidth, maxSmoothLineWidth]=Screen('DrawLines',expInfo.curWindow);
lineWidth = round(expInfo.ppd*0.61);
lineWidth = min(lineWidth,maxSmoothLineWidth);
lineLength = expInfo.ppd*5; %Line length in pixels-this visual degs into pixels
lineColor = [1];

if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    movie = Screen('CreateMovie', expInfo.curWindow, 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
end

%create a new gabor on every frame we present.
my_gabor = createGaborCorrectScale(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient,0,0);
my_noise = createLowPassNoise(2*radiusPix+1, smoothingSigmaPix, sigmaPix, 0,0);
my_noise = conditionInfo.noiseContrast*my_noise+.5;

my_mask = createGaussian(2*radiusPix+1, sigmaPix, 1,  0,0);
%Make a texture with a luminance and alpha plane;
my_mask = cat(3,0.5*ones(size(my_mask)),1-my_mask);
%my_noise = max(min(my_noise,.5),-.25);
%convert it to a texture 'tex'
gaborTex=Screen('makeTexture', expInfo.curWindow, my_gabor);
noiseTex = Screen('makeTexture', expInfo.curWindow, my_noise);
maskTex =  Screen('makeTexture', expInfo.curWindow, my_mask);


%draw the Gabor
Screen('DrawTexture', expInfo.curWindow, gaborTex, [], destRect, [], 0);
drawFixation(expInfo,expInfo.fixationInfo);
stimStartTime= Screen('Flip',expInfo.curWindow);
requestedStimEndTime=stimStartTime + conditionInfo.stimDuration;
Screen('Close',gaborTex);


%draw the mask
Screen('DrawTexture', expInfo.curWindow, noiseTex, [], destRect, [], 0);
drawFixation(expInfo,expInfo.fixationInfo);
actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);
Screen('Close',noiseTex);


%calculate mask offset time
requestedMaskEndTime = actualStimEndTime + 1;
drawFixation(expInfo,expInfo.fixationInfo);
actualMaskEndTime = Screen('Flip', expInfo.curWindow, requestedMaskEndTime);


%Calculate the fixation offset time
requestedFixEndTime = actualMaskEndTime + 0.25;
drawFixation(expInfo,expInfo.fixationInfo);
actualFixEndTime = Screen('Flip', expInfo.curWindow, requestedFixEndTime);




getParticipantResponse();

trialData.stimStartTime = stimStartTime;
trialData.stimEndTime   = actualStimEndTime;
trialData.maskEndTime   = actualMaskEndTime;
trialData.fixEndTime    = actualFixEndTime;

trialData.stimOri = wrapTo180(orient); %wrapTo180 makes angle go from[-180 180];
trialData.respError = minAngleDiff(trialData.stimOri,trialData.respOri);
trialData.feedbackMsg = ['Error: ' num2str(round(trialData.respError,1)) ' degrees'];

if conditionInfo.showFeedbackGabor
    showParticipantFeedback();
end

%This subroutine draws a line and allows it to be adjusted with a mouse or
%powermate. The funtion ends when a mouse button is clicked.
function getParticipantResponse()
        waitingForResponse = true;
        responseStartTime = GetSecs;
        lastFlipTime = responseStartTime;
        pollingInterval = 2*expInfo.ifi;
        
        SetMouse(expInfo.center(1),expInfo.center(2),expInfo.curWindow)
        %Randomize the line orientation
        initLineOri  = 360*rand();
        thisOrient = initLineOri;
        totalShift = 0;
        
        if expInfo.enablePowermate
            [buttons, dialPos] = PsychPowerMate('Get', expInfo.powermateId);

            xStart = dialPos;
            
        else %use the mouse
            [xStart,yStart] = GetMouse(expInfo.curWindow);
        end
       
        y = 0;
        x = xStart;
        
        %Store every the response angles. 
        nSamplesInit = round(15/expInfo.ifi);
        trialData.allRespData = NaN(nSamplesInit,2);
        
        %Rotation matrix;
        rotMtx = [cosd(initLineOri) -sind(initLineOri);...
            sind(initLineOri) cosd(initLineOri)];
        initXy = [0 0; lineLength -lineLength];
        xy = rotMtx'*initXy;
        responseIdx = 1;
        
        while waitingForResponse
            
            if isfield(expInfo,'writeMovie') && expInfo.writeMovie
                Screen('AddFrameToMovie', expInfo.curWindow,...
                    CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
            end
            
            if expInfo.enablePowermate
                lastDialPos = dialPos;
                [pMateButton, dialPos] = PsychPowerMate('Get', expInfo.powermateId);
                 [~,~,mouseButtons] = GetMouse(expInfo.curWindow);
             
                 buttons = [pMateButton mouseButtons];
                 dialSpeed = abs(dialPos-lastDialPos);
                 dialDir   = sign(dialPos-lastDialPos);
                 displacement = max(conditionInfo.powermateSpeed*dialSpeed,...
                     conditionInfo.powermateAccel*dialSpeed^1.85);
                  
                 x = x-dialDir*displacement;
                 
                 
                 
            else %use the mouse
                [x,y,buttons] = GetMouse(expInfo.curWindow);
            end
            
            timeNow = GetSecs;
            if any(buttons) && timeNow>(responseStartTime+.2); %Ok got a response lets quit
                trialData.responseTime = timeNow;
                waitingForResponse = false;
                
            else
                
                
                thisOrient = initLineOri+.25*(x-xStart);
            end
            
            
            
            
            %Rotation matrix;
            rotMtx = [cosd(thisOrient) -sind(thisOrient);...
                sind(thisOrient) cosd(thisOrient)];
            xy = rotMtx'*initXy;
            
            Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);
       
            thisFlipTime = Screen('Flip', expInfo.curWindow,lastFlipTime+pollingInterval+expInfo.ifi/2);
            trialData.allRespData(responseIdx,1) = thisOrient; 
            trialData.allRespData(responseIdx,2) = thisFlipTime; 
            responseIdx = responseIdx+1;
            lastFlipTime = thisFlipTime;
        end
        
        trialData.respStartTime = responseStartTime;
        trialData.respOri = wrapTo180(thisOrient);
    end
end
% % %
% % %
% % %


