  % Demo1
%
% Simple script for testing dots (dotsX)
%
% tests creating targets according to dots directions
% does not require response, just shows some targets and then the dots
try
    clear all
    %initialize the screen
    % touchscreen is 34, laptop is 32, viewsonic is 38
    screenInfo = openExperiment(34,50,0);
    %screenInfo = setupScreen(38,50)
    % initialize dots
    % look at createMinDotInfo to change parameters
    dotInfo = createMinDotInfoJMA(1);

%     dotInfo.apXYD = [-0 0 100;-0 0 100]; 
%     dotInfo.coh = [999;0]; 
%     dotInfo.wiggleSpeed = [dotInfo.speed/4; dotInfo.speed/4];
%     dotInfo.wiggleDir = [-90; -90];
%     
    
    dotInfo.numDotField = 1;
    dotInfo.apXYD = [-0 0 100;-100 0 100]; 
    %dotInfo.apXYD = [150 0 50; -150 0 50];
    dotInfo.speed = [100;0];
    dotInfo.coh = [1000;500];
    dotInfo.dir = [0;0];
    dotInfo.stochasticDir = [0;0]; % stochastically invert direction
    dotInfo.stochasticVelocity= [0;0];
    dotInfo.changeProb = [1; .00];
    
    dotInfo.maxDotTime    = [5];
    dotInfo.wiggleDir     = [0;0];
    dotInfo.wiggleSpeed   = [0;100];
    dotInfo.wiggleFreq    = [2];                    
    dotInfo.killPct       = 0;
    dotInfo.lifetime      = inf;
    dotInfo.nDotSets      = 1;   
    
    dotInfo.dotUpdateRate = 30;
    dotInfo.numFramesPer  =inf;
    
    dotInfo.frameByFrame = false;
    
    dotInfo.brownianNoise = true;

%     dotInfo.mouse =false;
%     dotInfo.keys =false;
    
    dotInfo.trackResponse = false;
     dotInfo.allowAdjustments = true;
    dotInfo.maxDotsPerFrame = 1000;
    dotInfo.dotDensity = 100;
    dotInfo.dotSize = 4;
%     dotInfo.wiggleFreq = 3.75;
%     dotInfo.maxDotTime =.5;
    
    [frames, rseed, start_time, end_time, response, response_time, stimulus,flipTimes] = dotsXJMA(screenInfo, dotInfo);
    %showTargets(screenInfo, targets, [1 2 3])
    pause(0.5)

    % clear the screen and exit
    closeExperiment;
    %closeScreen(screenInfo.curWindow, screenInfo.oldclut)
catch
    disp('caught')
    errorMsg = lasterror;
    %screenInfo
    closeExperiment;
    %closeScreen(screenInfo.curWindow, screenInfo.oldclut)
end;


