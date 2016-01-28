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
%   The paradigm file should be a function that takes expInfo as an
%   argument and returns a conditionInfo structure and expInfo back:
%
%   function [conditionInfo, expInfo] = exampleExperiment(expInfo)
%
%   conditionInfo defines all the conditions that will be run by psychMaster.
%   conditionInfo is a structure with an entry for each condtion that will be run
%    
%   Mandatory fields: nReps, trialFun, iti  
%   trialFun  = a function handle to the trial function
%   nReps     = number of reptitions to run this condition 
%               (each condition can have a different number).
%   iti       = The intertrial interval in seconds. Currently implemented
%               with a simple WaitSecs() call so the iti is AT LEAST this long
%   
%   Optional fields:
%   type = A string that identifies what type of trial, choices:
%          'Generic'  -  The @trialFun will handle collecting responses and
%                        feedback
%          '2afc'     -  This will implement 2 temporal alternative forced
%                        choice. This option will collect responses and 
%                        will optionally provide feedback (if giveFeedback is set to TRUE).  
%                        This type requires a special field in the condition 
%                        "nullCondition" that will be used as the 
%                        comparison trial.
%   
%   expInfo defines experiment wide settings. Mostly things that are
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
%   function [trialData] = trialFun(expInfo, conditionInfo)
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

    %This line calls the function handle that defines all the paradigm
    %information.  ConditionInfo contains the per condition information.
    %expInfo contains important 
    try
        [conditionInfo, expInfo] = sessionInfo.paradigmFun([]);
    catch
        disp('<><><><><><> PSYCH MASTER <><><><><><><>')
        disp('ERROR Loading Paradigm File')
        disp('<><><><><><> PSYCH MASTER <><><><><><><>')
        closeExperiment;
        return;
    end
    
    
    %     %!!!!!!!!!!!!!!!!!!!!!
    %     %VALUES ARE HARDCODED TEMPORARILY NEED TO INCORPORATE
    %     %CALIBRATION ROUTINE
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Load size calibration:
    if ispref('psychMaster','sizeCalibrationFile');
        sizeFile = getpref('psychMaster','sizeCalibrationFile');
        if ~exist(sizeFile,'file')
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Cannot find calibration file: ' sizeFile])
        else
            load(sizeFile); %loads the variable sizeCalibInfo
            expInfo.monitorWidth = sizeCalibInfo.monitorWidth;
            expInfo.sizeCalibInfo = sizeCalibInfo;
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Loading Size Calibration from: ' sizeFile])
        end
    else
        disp('<><><><><><> PSYCH MASTER <><><><><><><>')
        disp('NO SIZE CALIBRATION HAS BEEN SETUP. Guessing monitor size')
        
    end

        
    expInfo = openExperiment(expInfo);
    

    
    
    conditionInfo = validateConditions(conditionInfo);
    
    %This code randomizes the condition order

    nConditions = length(conditionInfo);
    
    if ~isfield(expInfo,'pauseInfo')
        expInfo.pauseInfo = 'Paused';
    end

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
    DrawFormattedTextStereo(expInfo.curWindow, expInfo.instructions,'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
    Screen('Flip', expInfo.curWindow);    
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
                
        %decide how to display trial depending on what type of trial it is.
        switch lower(conditionInfo(thisCond).type) 
            %generic trials just fire the trial function. Everything is
            %handled there.
            case 'generic'
                %ISI happens before a trial starts, this isn't a super-accurate way
                %to create an ISI, it makes an ISI at LEAST this big.
                WaitSecs(conditionInfo(thisCond).iti);
        
                [trialData] = conditionInfo(thisCond).trialFun(expInfo,conditionInfo(thisCond));
            case '2afc'
                
                %Which trial first?
                nullFirst = rand()>.5;
                
                if nullFirst
                    firstCond = conditionInfo(thisCond).nullCondition;
                    secondCond = conditionInfo(thisCond);
                else
                    firstCond = conditionInfo(thisCond);
                    secondCond = conditionInfo(thisCond).nullCondition;
                end
                
                trialData.nullFirst = nullFirst;
                [trialData.firstCond] = conditionInfo(thisCond).trialFun(expInfo,firstCond);
                WaitSecs(conditionInfo(thisCond).iti);
                [trialData.secondCond] = conditionInfo(thisCond).trialFun(expInfo,secondCond);
                
                [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                              
                trialData.firstPress = responseData.firstPress;
                trialData.pressed    = responseData.pressed;
                trialData.abortNow = false;
                
                
                if nullFirst
                    %If the null is first and the null is correct than 'F'
                    %is the correct response. 
                    if conditionInfo(thisCond).isNullCorrect
                        correctResponse   = 'f';
                        incorrectResponse = 'j';
                    else
                        %The null is first, but the null is incorrect so 
                        % 'j' is the correct response
                        correctResponse   = 'j';
                        incorrectResponse = 'f';
                    end
                else  %the null is second
                    
                    if conditionInfo(thisCond).isNullCorrect
                        %The null is correct and it is second the correct
                        %is 'j'
                        correctResponse   = 'j';
                        incorrectResponse = 'f';
                    else
                        %The null is second and it is incorrect so the
                        %correct answer is 'f'
                        correctResponse   = 'f';
                        incorrectResponse = 'j';
                    end
                end
                
                trialData.validTrial = false; %Default not valid unless proven otherwise
                if trialData.firstPress(KbName('ESCAPE'))
                    %pressed escape lets abort experiment;
                    trialData.validTrial = false;
                    trialData.abortNow = true;
                 
                elseif trialData.firstPress(KbName('space'))
                    trialData.validTrial = false;
                    DrawFormattedTextStereo(expInfo.curWindow, expInfo.pauseInfo, ...
                        'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                    Screen('Flip', expInfo.curWindow);
                    KbStrokeWait();
                    
                else      %Not aborting or pausing lets parse the inputs.
                    
                    %This section is kludgy. Could be done more elegantly,
                    %but I can't be bothered to make it pretty now. JMA
                    
                    %First setup which interval was chosen. 
                    if trialData.firstPress(KbName('f'))
                        experimentData(iTrial).chosenInterval = 1;
                    elseif trialData.firstPress(KbName('j'))
                        experimentData(iTrial).chosenInterval = 2;
                    end
                    
                    %Now 
                    if trialData.firstPress(KbName(correctResponse))
                        experimentData(iTrial).isResponseCorrect = true;
                        trialData.validTrial = true;
                        trialData.feedbackMsg = 'Correct';
                        
                    elseif trialData.firstPress(KbName(incorrectResponse))
                        experimentData(iTrial).isResponseCorrect = false;
                        trialData.validTrial = true;
                        trialData.feedbackMsg = 'Incorrect';                  
                    end
                end
                
        end
        
        
        experimentData(iTrial).condNumber = thisCond;               
        

        
        if ~trialData.validTrial  %trial not valid
            
            if trialData.abortNow
                break;
            end
            
            %Should add a message to the subject that they were too slow.
            conditionList(end+1) = conditionList(iTrial);
            validTrialList(iTrial) = false;
            experimentData(iTrial).validTrial = false;
            
            
            DrawFormattedTextStereo(expInfo.curWindow, 'Invalid trial','center', 'center', 1);
            
            Screen('Flip', expInfo.curWindow);
            WaitSecs(.5);
            Screen('Flip', expInfo.curWindow);
          
            %valid response made, should we give feedback?
        elseif conditionInfo(thisCond).giveFeedback 
            %Give feedback:
            DrawFormattedTextStereo(expInfo.curWindow, trialData.feedbackMsg,...
                'center', 'center', feedbackColor);
            Screen('Flip', expInfo.curWindow);
            WaitSecs(1.5);
            Screen('Flip', expInfo.curWindow);
        end
        
      
      experimentData(iTrial).trialData = trialData;
      iTrial = iTrial+1;
      
    end %End while loop for showing trials.
    
   % save(saveFilename,'experimentData')
   sessionInfo.expInfo = expInfo;
   sessionInfo.conditionInfo = conditionInfo;
  
   
   if isfield(expInfo,'paradigmName') && ~isempty(expInfo.paradigmName),       
       filePrefix = expInfo.paradigmName;
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
   
   if expInfo.useKbQueue
       KbQueueRelease(expInfo.deviceIndex);
   end
   
   
   
   
    closeExperiment;
    
   
    
catch
%    if expInfo.useKbQueue
%        KbQueueRelease(expInfo.deviceIndex);
%    end
    disp('caught')
    errorMsg = lasterror;
    closeExperiment;
    psychrethrow(psychlasterror);
    
end;
