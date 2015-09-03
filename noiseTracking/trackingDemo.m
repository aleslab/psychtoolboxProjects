%  
% Simple script for testing tracking experiment.
%
% tests creating targets according to dots directions
% does not require response, just shows some targets and then the dots
try
 
    %initialize the screen
    Screen('Preference', 'SkipSyncTests', 1);
    screenInfo = openWindowedExperiment(34,50,0);
    
    if ~exist('nreps','var')
        nreps = 0;
        accum=[];
    end
    
% Build a procedural gabor texture for a gabor with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
% Initial stimulus params for the gabor patch:
res = 1*[128 128];
phase = 90;
sc = 5.0;
freq = .05;
tilt = 0;
contrast = .50;
aspectratio = 1.0;
tw = res(1);
th = res(2);
halfX=8*tw/2;
halfY=8*th/2;
%tricky way to build the destination rect vector:
textureCenter = [ screenInfo.center] ;
textureVelocity = [0 0];
velocitySigma = 2;
destRec = [textureCenter textureCenter ] +[-halfX -halfY halfX halfY];
nonsymmetric = 0;
gabortex = CreateProceduralGabor(screenInfo.curWindow, tw, th, nonsymmetric, [0.5 0.5 0.5 0.0]);


trialDuration = 10000;
nFrames = round(trialDuration/screenInfo.frameDur);

keepShowing= true;
condInfo = [];
position = nan(nFrames,2);
velocity = nan(nFrames,2);
mousePos = nan(nFrames,2);


for iFrame=1:nFrames,
    
    %showTargets(screenInfo, targets, [1 2 3])
    
    velocity(iFrame,:) = textureVelocity;
    position(iFrame,:) = textureCenter;
    
   
    % Draw the Gabor patch: We simply draw the procedural texture as any other
    % texture via 'DrawTexture', but provide the parameters for the gabor as
    % optional 'auxParameters'.
    Screen('DrawTexture', screenInfo.curWindow, gabortex, [], destRec, 90+tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('flip',screenInfo.curWindow);
    [x,y] = GetMouse(screenInfo.curWindow);
    mousePos(iFrame,1) = x;
    mousePos(iFrame,2) = y;
    
    % [keyIsDown,secs, keyCode, deltaSecs] = KbCheck([]);
    textureVelocity =velocitySigma*randn(size(textureVelocity));
    
    textureCenter = textureCenter+textureVelocity;
    
    destRec = [textureCenter textureCenter] +[-halfX -halfY halfX halfY];
    
    isCorrect = NaN;
% 
%     if keyCode(41) %escape
%         
%     end
end


closeExperiment;


catch
    disp('caught')
    errorMsg = lasterror;
    %screenInfo
    closeExperiment;
    %closeScreen(screenInfo.curWindow, screenInfo.oldclut)
end;

maxlag=120;
t=linspace(-120*.01667,120*.01667,maxlag*2+1);
xVel = xcorr(diff(mousePos(:,1)),velocity(2:end,1),maxlag,'unbiased');
yVel = xcorr(diff(mousePos(:,2)),velocity(2:end,2),maxlag,'unbiased');
meanCorr = (xVel+yVel)/2;

if isempty(accum)
    accum = meanCorr;
else
    accum = accum+meanCorr;
end

nreps = nreps+1;
figure(101)
clf
plot(t,meanCorr,'--')
hold on
plot(t,accum/nreps);
xlabel('time in seconds')
legend('Single Trial result', 'Trial Average data')