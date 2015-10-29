function [] = psychMaster(sessionInfo)
%PSYCHMASTER  master script that invokes different experimental
%   [] = psychMaster()
%
%   This is the master script that runs a psychophysics session. 
%   when run it will ask for the participant ID and then ask you to 
%   select the experimental paradigm file. 
%   
%
%   paradigm file: 
%   The paradigm file should be a function that takes screenInfo as an
%   argument and returns a conditionInfo structure and screenInfo back:
%
%   function [conditionInfo, screenInfo] = exampleExperiment(screenInfo)
%
%   conditionInfo defines all the conditions that will be run by psychMaster.
%   conditionInfo is a structure with an entry for each condtion that will be run
%    
%   Mandatory fields: nReps, trialFun, iti  
%   trialFun = a function handle to the trial function
%   nReps    = number of reptitions to run this condition 
%              (each condition can have a different number).
%   iti      = The intertrial interval in seconds. Currently implemented
%              with a simple WaitSecs() call so the iti is AT LEAST this long
%   
%   screenInfo defines experiment wide settings. Mostly things that are
%   for PsychToolbox.  But also other things that are aren't specific to a
%   specific condition.  Mostly these are things that may be needed outside
%   the "trialFun". 
%
%   psychMaster will loop over the different conditions in the paradigm
%   file and run the conditionInfo.trialFun function to render the
%   stimulus.
%
%
%   Trial Function:
%   The trial function is what actually draws the stimulus.
%   function [trialData] = trialFun(screenInfo, conditionInfo)
%


% 10/2015 - created by Justin Ales
%
psychMasterVer = '.1';

%the sessionInfo structure is used to store information about the current session
%that is being run
if ~exist('sessionInfo','var') || isempty(sessionInfo)
    sessionInfo.participantID = input('What is the participant ID:  ','s');
    %store the date. use: datestr(sessionInfo.sessionDate) to make human readable
    sessionInfo.sessionDate = now;
    
    if ispref('psychMaster','lastParadigmFile')
        lastParadigmFile = getpref('psychMaster','lastParadigmFile');
    else
        lastParadigmFile = '';
    end
    
    [sessionInfo.paradigmFile, sessionInfo.paradigmPath] = ...
        uigetfile('*.m','Choose the experimental paradigm file',lastParadigmFile);
    
    lastParadigmFile = fullfile(sessionInfo.paradigmPath,sessionInfo.paradigmFile);
    
    setpref('psychMaster','lastParadigmFile',lastParadigmFile);
    
    [~, funcName ] = fileparts(sessionInfo.paradigmFile);
        sessionInfo.paradigmFun = str2func(funcName);

end

sessionInfo.psychMasterVer = psychMasterVer;

if exist(sessionInfo.paradigmFile,'file')~=2
   error('paradigm file is not in the current path')
end




%Check for preferences.  Preferences enable  easy configuration changes for
%different machines without having to hardcode things. 
%right now this just has some examples for setting per machine paths
if ~isempty(getpref('psychMaster'))

    if ispref('psychMaster','base');
        base = getpref('psychMaster','base');
    else
        base = [];
    end
    
    if isempty(base),     
        setpref('psychMaster','base',pwd); 
        disp(['Setting psychMaster directory preference to: ' pwd]);
    else
        disp(['Setting psychMaster home directory: ' base]);
    end    
    disp('Use the folowing command to change the base directory:');
    disp('setpref(''psychMaster'',''base'',/path/to/psychMaster); ');
    
    
    if ispref('psychMaster','datadir');
        datadir = getpref('psychMaster','datadir');
    else
        datadir = [];
    end
    
    if isempty(datadir),     
        setpref('psychMaster','datadir',fullfile(pwd,'Data')); 
        disp(['Setting psychMaster data directory preference to: ' fullfile(pwd,'Data')]);       
    else
        disp(['Saving data to: ' datadir]);
    end
    disp('Use the folowing command to change the data directory:');
    disp('setpref(''psychMaster'',''datadir'',/path/to/psychMaster/Data); ');

    
else

    disp('Use the folowing command to define a place to save data:');
    disp('setpref(''psychMaster'',''datadir'',/path/to/psychMaster/Data); ');
end

    

try

    %!!!!!!!!!!!!!!!!!!!!!
    %THESE VALUES ARE HARDCODED TEMPORARILY NEED TO INCORPORATE
    %CALIBRATION ROUTINE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    monitorWidth = 40; subjectDist = 50;
    expScreen = max(Screen('Screens'));   
    screenInfo = openExperiment(monitorWidth,subjectDist,expScreen,0);
    
    %This line calls the function handle that defines all the paradigm
    %information.  ConditionInfo contains the per condition information.
    %screenInfo contains important 
    [conditionInfo, screenInfo] = sessionInfo.paradigmFun(screenInfo);
    
 
   
    
    
    
    %This code randomizes the condition order

    nConditions = length(conditionInfo);

    %lets enumerate the total number of trials we need.
    %This type of loop construction where the index is incremented by
    %the loop is STRONGLY advised against. But I'm lazy and this works
    %Much more elegant and error-proof ways.
    idx = 1;
    for iCond = 1:nConditions,
        perCondData(iCond).correctResponse = [];
        
        for iRep = 1:conditionInfo(iCond).nReps,
            conditionList(idx) = iCond;
            idx = idx+1;
        end
    end
    
    %Now lets do a quick randomization. This is an old way to accomplish a
    %permutation
    [~,idx]=sort(rand(size(conditionList)));
    conditionList = conditionList(idx);
    
    
    
 
    %Now lets begin the experiment and loop over the conditions to show.
    
    %Show instructions and wait for a keypress. 
    DrawFormattedText(screenInfo.curWindow, screenInfo.instructions,'left', 'center', 1,[],[],[],[],[],screenInfo.screenRect);
    Screen('Flip', screenInfo.curWindow);    
    KbStrokeWait();
    %
    %Let's start the expeirment
    %we're going to use a while loop so we can easily add trials for
    %invalid trials.
    iTrial = 1;
    while iTrial <=length(conditionList)
    
        validTrialList(iTrial)= true;  %initialize this index variable to keep track of bad/aborted trials
        experimentData(iTrial).validTrial = true;
        feedbackMsg = [];
        feedbackColor = [1];
        
        thisCond = conditionList(iTrial);
                
        %ISI happens before a trial starts, this isn't a super-accurate way
        %to create an ISI, it makes an ISI at LEAST this big. 
        WaitSecs(conditionInfo(thisCond).iti);

        [trialData] = conditionInfo(thisCond).trialFun(screenInfo,conditionInfo(thisCond));
        experimentData(iTrial).condNumber = thisCond;
        
        %Determine what should be done depending on keypresses
        numKeysPressed = sum((trialData.firstPress>0));
        
        if ~trialData.validTrial  %trial not valid
            
            if trialData.abortNow
                break;
            end
            
            %Should add a message to the subject that they were too slow.
            conditionList(end+1) = conditionList(iTrial);
            validTrialList(iTrial) = false;
            experimentData(iTrial).validTrial = false;
            
            
            DrawFormattedText(screenInfo.curWindow, 'Invalid trial','center', 'center', 1);
            
            Screen('Flip', screenInfo.curWindow);
            WaitSecs(.5);
            Screen('Flip', screenInfo.curWindow);
            
        else %valid response made
            %Give feedback:
            DrawFormattedText(screenInfo.curWindow, trialData.feedbackMsg,...
                'center', 'center', feedbackColor);
            Screen('Flip', screenInfo.curWindow);
            WaitSecs(1.5);
            Screen('Flip', screenInfo.curWindow);
        end
        
      
      experimentData(iTrial).trialData = trialData;
      iTrial = iTrial+1;
      
    end
    
   % save(saveFilename,'experimentData')
   sessionInfo.screenInfo = screenInfo;
   sessionInfo.conditionInfo = conditionInfo;
  
   
   if isfield(screenInfo,'paradigmName') && ~isempty(screenInfo.paradigmName),       
       filePrefix = screenInfo.paradigmName;
   else
       filePrefix = func2str(sessionInfo.paradigmFun);
   end
   
   filename = [ filePrefix '_' ...
       sessionInfo.participantID '_' datestr(now,'yyyymmdd_HHMMSS') '.mat'];
   
    if ispref('psychMaster','datadir');
        datadir = getpref('psychMaster','datadir');
    else
        datadir = '';
    end
    
   saveFilename = fullfile(datadir,filename);
   
   if ~exist(datadir,'dir') 
       mkdir(datadir)
   end
   
   save(saveFilename,'sessionInfo','experimentData')
   
   if screenInfo.useKbQueue
       KbQueueRelease(screenInfo.deviceIndex);
   end
   
   
   
   
    closeExperiment;
    
   
    
catch
%    if screenInfo.useKbQueue
%        KbQueueRelease(screenInfo.deviceIndex);
%    end
    disp('caught')
    errorMsg = lasterror;
    closeExperiment;
    psychrethrow(psychlasterror);
    
end;
