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
    dotInfo.apXYD = [-0 0 200;-100 0 100]; 
    %dotInfo.apXYD = [150 0 50; -150 0 50];
    dotInfo.speed = [50;0];
    dotInfo.coh = [1000;500];
    dotInfo.dir = [0;0];
    dotInfo.stochasticDir = [0;0]; % stochastically invert direction
    dotInfo.stochasticVelocity = [0;0];
    dotInfo.changeProb = [.00; .00];
    
    dotInfo.maxDotTime    = [1];
    dotInfo.wiggleDir     = [0;0];
    dotInfo.wiggleSpeed   = [0;100];
    dotInfo.wiggleFreq    = [6];                    
    dotInfo.killPct       = 0;
    dotInfo.lifetime      = inf;
    dotInfo.nDotSets      = 1;   
    
    dotInfo.dotUpdateRate = 30;
    dotInfo.numFramesPer  =inf;
    
    dotInfo.frameByFrame = false;
    
    dotInfo.brownianNoise = false;

    dotInfo.mouse =false;
    dotInfo.keys =false;
    
    dotInfo.trackResponse = true;
     dotInfo.allowAdjustments = true;
    dotInfo.maxDotsPerFrame = 1000;
    dotInfo.dotDensity = 100;
    dotInfo.dotSize = 2;
%     dotInfo.wiggleFreq = 3.75;
%     dotInfo.maxDotTime =.5;
    
wiggleFreqList=dotInfo.dotUpdateRate./[2 5:2:15];

wiggleIdx = length(wiggleFreqList);

keepShowing= true;

while keepShowing,
    
    randDir = 360*rand-180;
    dotInfo.dir = [randDir;90];
    dotInfo.wiggleDir = [randDir+90;90];
    dotInfo.wiggleFreq = wiggleFreqList(wiggleIdx);
    
    [frames, rseed, start_time, end_time, response, response_time, stimulus,flipTimes] = dotsXJMA(screenInfo, dotInfo);
    %showTargets(screenInfo, targets, [1 2 3])
    
     [keyIsDown,secs, keyCode, deltaSecs] = KbCheck([]);
    
    isCorrect = NaN;
    if keyCode(80) %Left Arrow
        dotInfo.wiggleSpeed=max(0,dotInfo.wiggleSpeed-2);
        
    elseif keyCode(79) %Right Arrow
        dotInfo.wiggleSpeed=max(0,dotInfo.wiggleSpeed+2);
        
        
    elseif keyCode(30) %1
        dotInfo.lifetime = 1;
    elseif keyCode(31) %2
        dotInfo.lifetime = 2;
    elseif keyCode(32) %3
        dotInfo.lifetime = 3;
    elseif keyCode(33) %4
        dotInfo.lifetime = 4;
    elseif keyCode(34) %5
        dotInfo.lifetime = 5;
    elseif keyCode(35) %6
        dotInfo.lifetime = 6;
    elseif keyCode(36) %7
        dotInfo.lifetime = 7;
    elseif keyCode(37) %8
        dotInfo.lifetime = 8;
    elseif keyCode(38) %9
        dotInfo.lifetime = 9;
    elseif keyCode(39) %0
        dotInfo.lifetime = inf;
        
    elseif keyCode(26) %w
        wiggleIdx = mod(wiggleIdx,length(wiggleFreqList))+1;
    elseif keyCode(22) %s
        wiggleIdx = mod(wiggleIdx-2,length(wiggleFreqList))+1;        

    elseif keyCode(41) %escape
        closeExperiment;
        return;
        
    end
end

catch
    disp('caught')
    errorMsg = lasterror;
    %screenInfo
    closeExperiment;
    %closeScreen(screenInfo.curWindow, screenInfo.oldclut)
end;


