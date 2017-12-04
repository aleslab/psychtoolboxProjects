function [trialData] = step_gabor_trial_brownian(expInfo, conditionInfo)
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


%If no update is specified default to brownian.
if ~isfield( conditionInfo, 'updateMethod') || isempty(conditionInfo.updateMethod)
    conditionInfo.updateMethod = 'brownian';
end

persistent orient 
if isempty(orient);%if array is empty then orientation = 360 deg at random
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

getParticipantResponse();

trialData.stimStartTime = stimStartTime;
trialData.stimEndTime   = actualStimEndTime;
trialData.maskEndTime   = actualMaskEndTime;
trialData.fixEndTime    = actualFixEndTime;

trialData.validTrial = true;
trialData.stimOri = wrapTo180(orient); %wrapTo180 makes angle go from[-180 180];
trialData.feedbackMsg = [num2str(round(trialData.respOri)) ' degrees'];


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


