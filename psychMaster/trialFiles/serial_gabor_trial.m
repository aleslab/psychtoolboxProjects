function [trialData] = serial_gabor_trial(expInfo, conditionInfo)
% 
totalDuration = conditionInfo.preStimDuration+conditionInfo.stimDuration;
nFrames = round(totalDuration / expInfo.ifi);
nPreStimFrames=round(conditionInfo.preStimDuration/expInfo.ifi);
stimStartFrame = nPreStimFrames+1;

%trialData.actualDuration = nFrames*expInfo.ifi;
trialData.validTrial = false;
trialData.abortNow   = false;
% %Strictly speaking this  isn't the _best_ way to setup the timing
% %for rendering the stimulus but whatever.
conditionInfo.stimStartTime = GetSecs; %Get current time to start the clock
flipTimes = 2;
% trialData.mousePos = nan(nFrames,2);
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
radiusPix =    300;%expInfo.ppd*conditionInfo.stimRadiusDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = 2; %expInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
cyclesPerSigma =   20 %conditionInfo.freq;    %cycles per standaard devaion
contrast =  0.25;%conditionInfo.contrast;   % contrast 
phase = 90;      %phase of gabor
destRect = 300; %[ expInfo.center-radiusPix-1 expInfo.center+radiusPix  ];
=======
radiusPix = expInfo.ppd*conditionInfo.stimRadiusDeg;    % stimSize in degrees x pixels per degree.
sigmaPix  = expInfo.ppd*conditionInfo.sigma;  % standard deviation in degrees iinto pixels
cyclesPerSigma = conditionInfo.freq;    %cycles per standaard devaion
contrast = conditionInfo.contrast;   % contrast 
phase = 90;      %phase of gabor
destRect = [ expInfo.center-radiusPix-1 expInfo.center+radiusPix  ];
>>>>>>> origin/fraser

% orientationSigma=  15; %conditionInfo.orientationSigma;

%initAngularVelocity = 0;
%F = [1 0;0 1;];
    
orient = 360*(rand);

%Some parameters for the response line
lineWidth = 4;
lineLength =   100; %Line length in pixels
lineColor = [ 0 1 0 1];


% if isfield(expInfo,'writeMovie'); % expInfo.writeMovie
%     movie = Screen('CreateMovie'); %, %expInfo.curWindow,& 'MyTestMovie.mov', 1024, 1024, 30, ':CodecSettings=Videoquality=.9 Profile=2');
% end
% 



% if isfield(expInfo,'enablePowermate') 
%     if expInfo.enablePowermate
%         options.secs=0.0001;
%         err=PsychHID('ReceiveReports',expInfo.powermateId,options);
%     end
% end
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

<<<<<<< HEAD

%put gabor code in here?

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = windowRect(4) / 2;

% Sigma of Gaussian
sigma = gaborDimPix / 7;

% Obvious Parameters
orientation = 0;
contrast = 0.8;
aspectRatio = 1.0;
phase = 0;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 5;
freq = numCycles / gaborDimPix;


% my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
% my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
% my_noise = max(min(my_noise,.25),-.25);

tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);

Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);
Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center);

flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);

=======
%%%%%%%%
%%%% Put code that  draws the gabor here %%%%%
%%%%%%%%%%
>>>>>>> origin/fraser

stimStartTime= Screen('Flip',expInfo.curWindow);
requestedStimEndTime=stimStartTime + conditionInfo.stimDuration;
actualStimEndTime=Screen('Flip', expInfo.curWindow, requestedStimEndTime);

<<<<<<< HEAD
=======

getParticipantResponse();
>>>>>>> origin/fraser



<<<<<<< HEAD
%getParticipantResponse();

% trialData.stimStartTime = stimStartTime;
% trialData.stimEndTime   = actualStimEndTime;


%for iFrame = 1:nFrames
%for iFrame = 1
=======
% %for iFrame = 1:nFrames
% for iFrame = 1
>>>>>>> origin/fraser
% 
%
%     
%     %creates a gabor texture. this has to be in the loop beacuse we want to
%     %create a new gabor on every frame we present.
%     my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
<<<<<<< HEAD
 %    my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
   %  my_noise = max(min(my_noise,.25),-.25);
%     %convert it to a texture 'tex'
  %  tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);
   % Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);
    %Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center);
=======
%     my_noise = conditionInfo.noiseSigma.*randn(size(my_gabor));
%     my_noise = max(min(my_noise,.25),-.25);
%     %convert it to a texture 'tex'
%     tex=Screen('makeTexture', expInfo.curWindow, my_gabor+my_noise);
%     Screen('DrawTexture', expInfo.curWindow, tex, [], destRect, [], 0);
%     Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center);
>>>>>>> origin/fraser
% 
%     
%     
%     
<<<<<<< HEAD
    %  if expInfo.enablePowermate
    %     Screen('DrawingFinished',expInfo.curWindow,expInfo.dontclear);
     %    err=PsychHID('ReceiveReports',expInfo.powermateId,options);
      %end
%     
    % flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
    % WaitSecs(2);
%     
    % if isfield(expInfo,'writeMovie') && expInfo.writeMovie
     %    Screen('AddFrameToMovie', expInfo.curWindow,...
       %     CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
  %  end
%     
  %  if expInfo.enablePowermate
      %   err=PsychHID('ReceiveReports',expInfo.powermateId,options);
      %   r=PsychHID('GiveMeReports',expInfo.powermateId);
        % if ~isempty(r)
          %   lastY = y(end);
          %   y =[cat(1,r(:).report)];
            % y = typecast(uint8(y(:,2)),'int8');
           %  y = double(y);
           %  y = [lastY; y];
           %  t = [ 1000*([ lastT r(:).time]-r(1).time) ];
           %  lastT = r(end).time;
%             
            % report(iFrame).r = r;
%             
            % thisShift = .5*trapz(t,y);
            % totalShift= totalShift-thisShift;            
       %  end
       %  y = 0;
        % lastT = GetSecs;
%         
       %  trialData.respOri(iFrame) =  initLineOri+totalShift;
   %  else
     %    [x,y] = GetMouse(expInfo.curWindow);
     %    trialData.mousePos(iFrame,1) = x-xStart;
     %    trialData.mousePos(iFrame,2) = y-yStart;
      %   trialData.respOri(iFrame) = initLineOri+.5*(x-xStart);
    % end
%     
   %  trialData.stimOri(iFrame) = orient;
     %Rotation matrix; 
   %  rotMtx = [cosd(trialData.respOri(iFrame)) -sind(trialData.respOri(iFrame));...
     %      sind(trialData.respOri(iFrame)) cosd(trialData.respOri(iFrame))];
   %  xy = rotMtx'*initXy;
%     
    % if expInfo.enablePowermate
      %   err=PsychHID('ReceiveReports',expInfo.powermateId,options);
  %   end
    %release the texture after we flip because we will redraw again in this
%     %loop.
    % Screen('Close', tex);
    % if expInfo.useKbQueue
    %     [ trialData.pressed, trialData.firstPress]=KbQueueCheck(expInfo.deviceIndex);
   %  else
      %  [ trialData.pressed, secs, keyCode]=KbCheck(expInfo.deviceIndex);
      %  trialData.firstPress = secs*keyCode;
    % end
=======
%      if expInfo.enablePowermate
%          Screen('DrawingFinished',expInfo.curWindow,expInfo.dontclear);
%          err=PsychHID('ReceiveReports',expInfo.powermateId,options);
%      end
%     
%     flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
%     %WaitSecs(2);
%     
%     if isfield(expInfo,'writeMovie') && expInfo.writeMovie
%         Screen('AddFrameToMovie', expInfo.curWindow,...
%             CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
%     end
%     
%     if expInfo.enablePowermate
%         err=PsychHID('ReceiveReports',expInfo.powermateId,options);
%         r=PsychHID('GiveMeReports',expInfo.powermateId);
%         if ~isempty(r)
%             lastY = y(end);
%             y =[cat(1,r(:).report)];
%             y = typecast(uint8(y(:,2)),'int8');
%             y = double(y);
%             y = [lastY; y];
%             t = [ 1000*([ lastT r(:).time]-r(1).time) ];
%             lastT = r(end).time;
%             
%             report(iFrame).r = r;
%             
%             thisShift = .5*trapz(t,y);
%             totalShift= totalShift-thisShift;            
%         end
%         y = 0;
%         lastT = GetSecs;
%         
%         trialData.respOri(iFrame) =  initLineOri+totalShift;
%     else
%         [x,y] = GetMouse(expInfo.curWindow);
%         trialData.mousePos(iFrame,1) = x-xStart;
%         trialData.mousePos(iFrame,2) = y-yStart;
%         trialData.respOri(iFrame) = initLineOri+.5*(x-xStart);
%     end
%     
%     trialData.stimOri(iFrame) = orient;
%     %Rotation matrix; 
%     rotMtx = [cosd(trialData.respOri(iFrame)) -sind(trialData.respOri(iFrame));...
%           sind(trialData.respOri(iFrame)) cosd(trialData.respOri(iFrame))];
%     xy = rotMtx'*initXy;
%     
%     if expInfo.enablePowermate
%         err=PsychHID('ReceiveReports',expInfo.powermateId,options);
%     end
%     %release the texture after we flip because we will redraw again in this
%     %loop.
%     Screen('Close', tex);
%     if expInfo.useKbQueue
%         [ trialData.pressed, trialData.firstPress]=KbQueueCheck(expInfo.deviceIndex);
%     else
%         [ trialData.pressed, secs, keyCode]=KbCheck(expInfo.deviceIndex);
%         trialData.firstPress = secs*keyCode;
%     end
>>>>>>> origin/fraser
%     
%     
%     %Pressed too early.  Abort trial and put in some default values in the
%     %returned data.
<<<<<<< HEAD
  %  if trialData.pressed
 %                 trialData.pressed = false;
%                 trialData.firstPress = zeros(size(trialData.firstPress));
 %       flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
 %       trialData.flipTimes = flipTimes;
  %      trialData.validTrial = false;
  %      return;
%         
% 
   % end
=======
%     if trialData.pressed
%         %         trialData.pressed = false;
%         %         trialData.firstPress = zeros(size(trialData.firstPress));
%         flipTimes(iFrame)=Screen('Flip', expInfo.curWindow);
%         trialData.flipTimes = flipTimes;
%         trialData.validTrial = false;
%         return;
%         
% 
%     end
>>>>>>> origin/fraser
%     
% end
% 
% Screen('Flip', expInfo.curWindow);
% trialData.validTrial = true;

% Finalize and close movie file, if any:
% if isfield(expInfo,'writeMovie') && expInfo.writeMovie
  %  Screen('FinalizeMovie', movie);
% end
% curTime = GetSecs;

%Flush any events that happend before the end of the trial
% if expInfo.useKbQueue
  %  KbQueueFlush();
% end

% trialData.feedbackMsg = [num2str(round(trialData.respOri)) ' degrees'];


%Reset times to be with respect to trial end.
%trialData.firstPress = trialData.firstPress-trialData.flipTimes(end);

<<<<<<< HEAD
% function  [getParticipantResponse()]
         %  waitingForResponse = true;
          % initLineOri  = 360*rand();
          % totalShift = 0;
          % xStart,yStart] = GetMouse(expInfo.curWindow);
          % y = 0;
=======
    function getParticipantResponse()
        
        waitingForResponse = true;
        initLineOri  = 360*rand();
        totalShift = 0;
        [xStart,yStart] = GetMouse(expInfo.curWindow);
        y = 0;
>>>>>>> origin/fraser
      
       
        %Rotation matrix;
       % rotMtx = [cosd(initLineOri) -sind(initLineOri);...
          %  sind(initLineOri) cosd(initLineOri)];
       % initXy = [0 0; lineLength -lineLength];
       % xy = rotMtx'*initXy;
        
       % while waitingForResponse
             
<<<<<<< HEAD
          %  if isfield(expInfo,'writeMovie') && expInfo.writeMovie
            %    Screen('AddFrameToMovie', expInfo.curWindow,...
             %   CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
% end
=======
            if isfield(expInfo,'writeMovie') && expInfo.writeMovie
                Screen('AddFrameToMovie', expInfo.curWindow,...
                    CenterRect([0 0 1024 1024], Screen('Rect', expInfo.curWindow)));
            end
>>>>>>> origin/fraser
            
       %     if expInfo.enablePowermate
        %        err=PsychHID('ReceiveReports',expInfo.powermateId,options);
          %      r=PsychHID('GiveMeReports',expInfo.powermateId);
            %    if ~isempty(r)
             %       lastY = y(end);
              %      y =[cat(1,r(:).report)];
                 %   y = typecast(uint8(y(:,2)),'int8');
                %    y = double(y);
                %    y = [lastY; y];
                %    t = [ 1000*([ lastT r(:).time]-r(1).time) ];
                  %  lastT = r(end).time;
                    
                 %   report(iFrame).r = r;
                    
                   % thisShift = .5*trapz(t,y);
                   % totalShift= totalShift-thisShift;
              %  end
             %   y = 0;
              %  lastT = GetSecs;
                
               % thisOrient =  initLineOri+totalShift;
          %  else %use the mouse
             %   [x,y,buttons] = GetMouse(expInfo.curWindow);
                
              %  if any(buttons); %Ok got a response lets quit
                %    waitingForResponse = false;
                 %   trialData.responseTime = GetSecs;
               % else
                   % thisOrient = initLineOri+.5*(x-xStart);
             %   end
                
         %   end

         
            %Rotation matrix;
           % rotMtx = [cosd(thisOrient) -sind(thisOrient);...
            %    sind(thisOrient) cosd(thisOrient)];
          %  xy = rotMtx'*initXy;
            
          %  Screen('DrawLines', expInfo.curWindow, xy,lineWidth,lineColor,expInfo.center,1);
            
          %  Screen('Flip', expInfo.curWindow);
            
            
        
<<<<<<< HEAD
     %   end
        
     %   trialData.respOri = thisOrient;
% end 
% end
=======
            end
        
        trialData.respOri = thisOrient;
        
        
    end
>>>>>>> origin/fraser


end

