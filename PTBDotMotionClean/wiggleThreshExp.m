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
%    screenInfo = openExperiment(34,50,0);
    screenInfo = openExperiment(30,100,0);

    %screenInfo = setupScreen(38,50)
    
    %Setup filenames
    saveDir = '.';
    thisFilename = ['wiggleThresh_' datestr(now,'yyyymmdd_HHMM') '.mat'];

    thisFilename = fullfile(saveDir,thisFilename);
    pixWidth = 10*(1/screenInfo.ppd); %pixelwidth in 10*degrees
    % initialize dots
    % look at createMinDotInfo to change parameters
    dotInfo = createMinDotInfoJMA(1);
    
    % initiate feedback sound
    [freq beepmatrix] = createSound;

    randomizeCarrierDirection = true;
    nTrialsPerCondition = 40;
    
    dotInfo.numDotField = 1;
    dotInfo.apXYD = [0 0 100;-50 0 100]; 
    %dotInfo.apXYD = [150 0 50; -150 0 50];
    dotInfo.speed = [60;100];
    dotInfo.coh = [1000;1000];
    dotInfo.dir = [90;90];
    dotInfo.stochasticDir = [0;0]; % stochastically invert direction
    dotInfo.changeProb = [.00; .00];
    
    dotInfo.maxDotTime    = [.5];
    dotInfo.wiggleDir     = [0;0];
    dotInfo.wiggleSpeed   = [10;10];
    dotInfo.wiggleFreq    = [3];                    
    dotInfo.killPct       = 0;
    dotInfo.lifetime      = 2;
    dotInfo.nDotSets      = 1;   
    
    dotInfo.dotUpdateRate = 30;
    dotInfo.numFramesPer  =2;
    
    dotInfo.frameByFrame = false;
    
    dotInfo.brownianNoise = false;

    dotInfo.mouse =[];
    dotInfo.keys =1;
    
    dotInfo.trackResponse = false;
    dotInfo.allowAdjustments = false;
    dotInfo.maxDotsPerFrame = 1000;
    dotInfo.dotDensity = 50;
    dotInfo.dotSize = 4;
%   dotInfo.wiggleFreq = 3.75;
%   dotInfo.maxDotTime =.5;





wiggleFreqList = 15;7.5;[60./(8:2:26)];
lifetimeList   = inf;[12 inf];

nWiggles = length(wiggleFreqList);
nLifetimes = length(lifetimeList);


wiggleOrder   = 1:length(wiggleFreqList);
lifetimeOrder = 1:length(lifetimeList);

[aWig aLife] = ndgrid(wiggleOrder,lifetimeOrder);
allCond = [aWig(:) aLife(:)];

nCond = length(wiggleFreqList)*length(lifetimeList);


iTrial = 1;
trialsLeft = true;
trialCount=zeros(length(wiggleFreqList),length(lifetimeList));

wiggleAmp{length(wiggleFreqList),length(lifetimeList)}= [];
subjectResponse{length(wiggleFreqList),length(lifetimeList)}=[];


%Setup QUEST parameters
tGuess=-.5;
tGuessSd=4;
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
grain =.001;
range = 5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

[questStructs{1:nWiggles,1:nLifetimes}] = deal(q);


while trialsLeft,
    
    
%     %Permute the list of wiggles
%     wiggleOrder   = wiggleOrder(randperm(length(wiggleOrder)));
%     lifetimeOrder = lifetimeOrder(randperm(length(lifetimeOrder)));

    thisCond = ceil(nCond*rand);
    
    thisWiggleIdx = allCond(thisCond,1);
    thisLifetimeIdx = allCond(thisCond,2);
    
    
    thisWiggleFreq = wiggleFreqList(thisWiggleIdx);
    thisLifetime   = lifetimeList(thisLifetimeIdx);
    
    trialDotInfo = dotInfo;    
    trialDotInfo.lifetime = thisLifetime;
    trialDotInfo.wiggleFreq = thisWiggleFreq;

    tTest=QuestQuantile(questStructs{thisWiggleIdx,thisLifetimeIdx});

    
    %Set by method
    tTest = exp(tTest);
    %Minimum wiggle amount is pixwidth
    thisAmp = max(pixWidth,tTest+.02*randn*tTest);
    
    %Maximum wiggle is 1/20 aperture
    thisAmp = min(dotInfo.apXYD(1,3)/20,thisAmp);
    
    dotInfo1st = trialDotInfo;
    dotInfo2nd = trialDotInfo;
    
    if randomizeCarrierDirection        
        randDir = 360*rand-180;
        dotInfo1st.dir = [randDir;90];
        dotInfo1st.wiggleDir = [randDir+90;90];

        randDir = 360*rand-180;
        dotInfo2nd.dir = [randDir;90];
        dotInfo2nd.wiggleDir = [randDir+90;90];

    end

    
    
    if rand>.5;

        dotInfo1st.wiggleSpeed = [0;thisAmp];
        dotInfo2nd.wiggleSpeed = [thisAmp;0;];
        trialData(iTrial).stimIn = 2;
        
    else
        dotInfo1st.wiggleSpeed = [thisAmp;0];
        dotInfo2nd.wiggleSpeed = [0;thisAmp];
        trialData(iTrial).stimIn = 1;
        
    end
    
    
            
    [frames1, rseed1, start_time, end_time, response1, response_time1, stimulus1,flipTimes1] = dotsXJMA(screenInfo, dotInfo1st);

    WaitSecs(.1);
    [frames2, rseed2, start_time, end_time, response2, response_time2, stimulus2,flipTimes2] = dotsXJMA(screenInfo, dotInfo2nd);

    [secs, keyCode, deltaSecs] = KbWait([],2);
    
    isCorrect = NaN;
    if keyCode(80) %Left Arrow
        
        if trialData(iTrial).stimIn ==1
            isCorrect = true;
        else
            isCorrect = false;
        end
        
    elseif keyCode(79) %Right Arrow

        if trialData(iTrial).stimIn ==2
            isCorrect = true;
        else
            isCorrect = false;
            
            
        end
        
    elseif keyCode(41) %escape
        closeExperiment;
        return;
        
    end

    
    if isCorrect
        sound(beepmatrix,freq)    
    else
        sound(beepmatrix,freq)
        %etime(clock,t0)
        WaitSecs(0.1);
        sound(beepmatrix,freq)
    end
    
    wiggleAmp{thisWiggleIdx,thisLifetimeIdx}(end+1) = thisAmp;
    subjectResponse{thisWiggleIdx,thisLifetimeIdx}(end+1) = isCorrect;
    
    questStructs{thisWiggleIdx,thisLifetimeIdx}=QuestUpdate(questStructs{thisWiggleIdx,thisLifetimeIdx},log(thisAmp),isCorrect);
        
    trialData(iTrial).dotInfo1st = dotInfo1st;
    trialData(iTrial).dotInfo2nd = dotInfo2nd;
    trialData(iTrial).thisWiggle = thisWiggleFreq;
    trialData(iTrial).thisLifetime = thisLifetime;
    

    trialData(iTrial).flipTimes1 = flipTimes1;
    trialData(iTrial).response1 = response1;
    trialData(iTrial).rseed1 = rseed1;
    
    trialData(iTrial).flipTimes2 = flipTimes2;
    trialData(iTrial).response2 = response2;
    trialData(iTrial).rseed2 = rseed2;
    
    iTrial = iTrial+1;
    
    trialCount(thisWiggleIdx,thisLifetimeIdx) =     trialCount(thisWiggleIdx,thisLifetimeIdx)+1;
    
    if mod(iTrial,10) ==0;
        save(thisFilename,'questStructs', 'subjectResponse', 'wiggleAmp', 'trialData');
    end
    
    
    %If we have enough trials.
     if trialCount(thisWiggleIdx,thisLifetimeIdx) >= nTrialsPerCondition;
         
         nCond = nCond-1;
         allCond(thisCond,:) = [];
         
         if isempty(allCond)
             display('All done')
             save thisFilename questStructs subjectResponse wiggleAmp trialData
             break; 
         end
                     
     end
    
%    pause(.5)
    
end

    
    
    %showTargets(screenInfo, targets, [1 2 3])

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


