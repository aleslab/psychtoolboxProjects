function [trialData] = dep_gabor_trial(expInfo, conditionInfo)
%test edit

trialData.validTrial = true;
trialData.abortNow   = false;
%Strictly speaking this  isn't the _best_ way to setup the timing
%for rendering the stimulus but whatever.
trialData.stimStartTime = GetSecs; %Get current time to start the clock

feedbackDur = 2;
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


%Check for optional fields presence.  If not set to default values. 

if ~isfield(expInfo,'enableKeyboard')
    expInfo.enableKeyboard = false;
end

if ~isfield(conditionInfo,'showFeedbackGabor')
    conditionInfo.showFeedbackGabor = false;
end


if isfield(conditionInfo,'gaborCenterX')
    gaborCenterXPix = expInfo.ppd*conditionInfo.gaborCenterX;
else
    gaborCenterXPix = 0;
end

if isfield(conditionInfo,'gaborCenterY')
    gaborCenterYPix = expInfo.ppd*conditionInfo.gaborCenterY;
else
    gaborCenterYPix = 0;
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

persistent orient;
if isempty(orient);
    orient=360*rand;
end

switch lower(conditionInfo.updateMethod)
    case 'brownian' %brownian motion updates from last trial
        orient = orient + randn*conditionInfo.orientationSigma;
    case 'uniform' %draws a uniform orientation from 360 degrees
        orient = rand*360;
        
end




%Some parameters for the response line
lineWidth = 4;
lineLength = expInfo.ppd*3; %Line length in pixels-this visual degs into pixels
lineColor = [1];


if isfield(expInfo,'writeMovie') && expInfo.writeMovie
    movie = Screen('CreateMovie', expInfo.curWindow, 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
end




%create a new gabor on every frame we present.
my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient,gaborCenterXPix,gaborCenterYPix);
my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
%my_noise = max(min(my_noise,.5),-.25);
%convert it to a texture 'tex'
tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);

%draw the Gabor
Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);

drawFixation(expInfo,expInfo.fixationInfo);
stimStartTime= Screen('Flip',expInfo.curWindow);
requestedStimEndTime=stimStartTime + conditionInfo.stimDuration;
Screen('Close',tex);

%draw the mask
noiseMask = conditionInfo.noiseSigma.*randn(size(my_gabor));
maskTex=Screen('makeTexture', expInfo.curWindow, noiseMask+0.5);
Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);

drawFixation(expInfo,expInfo.fixationInfo);
actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);
Screen('Close',maskTex);

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
        pollingInterval = 1*expInfo.ifi;
        
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
        
        oriIncrement = 0;
        
       
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
        
        prevPollPresses = 0;
        
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
            
            incVal = .5;
            
            if expInfo.enableKeyboard
           
                %Wait up to half a polling interval for a response
                [ keyRespData ] = getResponse(expInfo,pollingInterval/2);
                if keyRespData.firstPress(KbName('space'))
                    buttons(1) = true; %Ok this is a silly thing, If a space bar is pressed treat as a mouse button click to stop trial.
                end
                
                if keyRespData.pressed
                    prevPollPresses = prevPollPresses+1;
                else
                    prevPollPresses = 0;
                end
                
                %If button is held down for 5 polling checks in a row speed
                %up the rotation.
                if prevPollPresses > 5
                    incVal = 3;
                else
                    incVal = .4;
                end
                
                if keyRespData.firstPress(KbName('f')) || keyRespData.firstPress(KbName('LeftArrow'))
                    oriIncrement = oriIncrement + incVal;
                elseif keyRespData.firstPress(KbName('j')) || keyRespData.firstPress(KbName('RightArrow'))
                    oriIncrement = oriIncrement - incVal;
                end
                
                %No matter what is parsed above. If 'ESCAPE' is pressed
                %always abort
                if keyRespData.firstPress(KbName('ESCAPE'))
                    %pressed escape lets abort experiment;
                    trialData.validTrial = false;
                    trialData.abortNow = true
                    waitingForResponse = false;
                end
                
            end
            
            timeNow = GetSecs;
            if any(buttons) && timeNow>(responseStartTime+.2); %Minimum response time of 200 ms. 
              
                trialData.responseTime = timeNow;
                waitingForResponse = false;
                
            else
                
                
                thisOrient = initLineOri+.25*(x-xStart)+oriIncrement;
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


 function showParticipantFeedback()

     %create a new gabor on every frame we present.
     feedbackContrast = .8;
     my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, feedbackContrast, phase, orient);
     %my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
     %my_noise = max(min(my_noise,.5),-.25);
     %convert it to a texture 'tex'
     tex=Screen('makeTexture', expInfo.curWindow, my_gabor);

     %draw the Gabor
     Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);

 
     rotMtx = [cosd(trialData.respOri) -sind(trialData.respOri);...
         sind(trialData.respOri) cosd(trialData.respOri)];
     initXy = [0 0; lineLength -lineLength];
     xy = rotMtx'*initXy;
     
     Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);
     
     
     DrawFormattedTextStereo(expInfo.curWindow, trialData.feedbackMsg,...
                        'center', [], 1);
     
     thisFlipTime = Screen('Flip', expInfo.curWindow);
     drawFixation(expInfo,expInfo.fixationInfo);
     Screen('Flip', expInfo.curWindow,thisFlipTime+feedbackDur);
 
     Screen('Close',tex);

 end
% % %
% % %
% % %




end