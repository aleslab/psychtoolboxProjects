function [] = psychMaster(sessionInfo)
%PSYCHMASTER  master script that invokes different experimental
%   [] = psychMaster()
%
%   This is the master script that runs a psychophysics session.
%   when run it will spawn a GUI that asks for required information and
%   allows for inspecting condition parameters and testing individual
%   trials.
%
%
%   paradigm file:
%   The paradigm file should be a function that takes expInfo as an
%   argument and returns a conditionInfo structure and expInfo back:
%
%   function [conditionInfo, expInfo] = exampleExperiment()
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
%
%   Optional fields with defaults in []:f
%   label        = [''] A short string that identifies the condition
%                  e.g. 'vertical', 'Contrast: 25', or  'Target: Red'
%   giveFeedback = [false] Bolean whether to print feedback after trial
%   type = ['generic'] A string that identifies what type of trial, choices:
%          'Generic'  -  The most basic trial handling. Only handles
%                        randomizing, trial presentation and saving data.
%                        The @trialFun will handle collecting responses and
%                        feedback
%    'simpleResponse' -  Like 'Generic' but waits for a response after
%                        every trial and saves it.
%          '2afc'     -  This will implement 2 temporal alternative forced
%                        choice. This option will collect responses and
%                        will optionally provide feedback (if giveFeedback is set to TRUE).
%                          Requires 2 extra fields:
%                          nullCondition = a conditionInfo structure with a
%                                          single condition that will be used
%                                          as the comparison
%                          isNullCorrect = [false] a boolean that sets which
%                                          condition is the correct condition.
%                                          If set to true the null condition
%                                          is treated as correct. If set to
%                                          false (default) the other condition
%                                          is considered correct.
%   'directionreport' - For dealing with data from a direction
%                       discrimination task where there are 8 different
%                       options for response in a "circle".
%
%   expInfo defines experiment wide settings. Mostly things that are
%   for PsychToolbox.  But also other things that are aren't specific to a
%   specific condition.  Mostly these are things that may be needed outside
%   the "trialFun". See help openExperiment for more information.
%
%   Notable expInfo fields:
%   viewingDistance =  [57] The viewing distance in cm. 
%     
%   instructions    = [''] A message to display before the start of
%                      experiment
%
%   randomizationType = ['random'] a short string that sets how trials are
%                      randomized it can take the following values:
%              'random' - fully randomize all conditions
%              'blocked' - repeatedly present a condition nReps time than
%                          switch conditions. But present conditions in random order.
%   
%   stereoMode = [0] A number selecting a PTB stereomode. 
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

%Initial setup

psychMasterVer = '0.20';

thisFile = mfilename('fullpath');
[thisDir, ~, ~] = fileparts(thisFile);


%Check if path is correct, if not try and fix it. 
if ~checkPath()
    disp('<><><><><><> PSYCH MASTER <><><><><><><>')
    setupPath();
    if ~checkPath()
        disp('PATH NOT CORRECT!  Attempts to fix failed!  ABORTING!')
        disp('This problem suggests that files have been moved or cannot be found.')
        disp('You will have to setup your path manually or fix the broken structure.')
        return;
    end
    disp('Path was not setup correctly, but we auto fixed it.  In the future  check your path setup')
end


%Save matlab output to file:
diaryName = fullfile(thisDir,['tmp_MatlabLog_' datestr(now,'yyyymmdd_HHMMSS') '.txt' ]);
diary(diaryName);

%the sessionInfo structure is used to store information about the current session
%that is being run
if ~exist('sessionInfo','var') || isempty(sessionInfo)
    %  sessionInfo.participantID = input('What is the participant ID:  ','s');
    %store the date. use: datestr(sessionInfo.sessionDate) to make human readable
    sessionInfo.sessionDate = now;
    sessionInfo.psychMasterVer = psychMasterVer;
    [~,ptbVerStruct]=PsychtoolboxVersion;
    sessionInfo.ptbVersion = ptbVerStruct;
    rng('default'); %Need to reset the rng before shuffling in case the legacy RNG has activated before we started psychMaster
    rng('shuffle');
    sessionInfo.randomSeed = rng;
end


expInfo     = struct();

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
    
    %Load size calibration:
    if ispref('psychMaster','sizeCalibrationFile');
        sizeFile = getpref('psychMaster','sizeCalibrationFile');
        if ~exist(sizeFile,'file')
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Cannot find calibration file: ' sizeFile])
        else
            sizeCalibInfo = load(sizeFile); %loads the variable sizeCalibInfo
            expInfo.monitorWidth = sizeCalibInfo.monitorWidth;
            expInfo.sizeCalibInfo = sizeCalibInfo;
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Loading Size Calibration from: ' sizeFile])
        end
    else
        disp('<><><><><><> PSYCH MASTER <><><><><><><>')
        disp('NO SIZE CALIBRATION HAS BEEN SETUP. Guessing monitor size')
        
    end
    
    %Load luminance calibration:
    if ispref('psychMaster','lumCalibrationFile');
        luminanceFile = getpref('psychMaster','lumCalibrationFile');
        if ~exist(luminanceFile,'file') %a calibration is set but doesn't exist.
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Cannot find calibration file: ' luminanceFile])
            
        else %we found the file, now load it.
            lumInfo = load(luminanceFile);
            disp('<><><><><><> PSYCH MASTER <><><><><><><>')
            disp(['Loading Size Calibration from: ' luminanceFile])
            expInfo.gammaTable = lumInfo.gammaTable;
            expInfo.lumCalibInfo = lumInfo;
        end
    else
        disp('<><><><><><> PSYCH MASTER <><><><><><><>')
        disp('NO LUMINANCE CALIBRATION HAS BEEN SETUP. Using Identiy LUT')
        
    end
    
    
    %Try to get the git commit hash and save it to the expInfo
    %
    %JMA: This only works for a current git repository.
    %TODO: Add a mechanism for including this information in standalone
    %builds.
    %Fix this to get the right directory
    [errorStatus,result]= system('git rev-parse --verify HEAD');
    
    if ~errorStatus
        sessionInfo.gitHash = result;
    else
        sessionInfo.gitHash = '         ';
    end
    
    %loop to enable firing single conditions for testing, could also be
    %extended to multiple blocks in the future.
    [sessionInfo,expInfo,conditionInfo] = pmGui(sessionInfo,expInfo);
    drawnow; %<- required to actually close the gui.
    
    %User canceled before opening experiment, just quit the function.
    if sessionInfo.userCancelled
        cleanupPsychMaster();
        return;
    end
    
    
    %Now lets begin the experiment and loop over the conditions to show.
    expInfo = openExperiment(expInfo);
    
    
    %Initialize experiment data, this makes sure the experiment data
    %scope spans all the subfunctions.
    experimentData = struct();
    %This function handles everything for the experimental trials.
    mainExperimentLoop();
    
    %If 
    while sessionInfo.returnToGui
        
        [sessionInfo,expInfo,conditionInfo] = pmGui(sessionInfo,expInfo,sessionInfo.backupConditionInfo);
        drawnow; %<- required to actually close the gui.
        
        %User canceled after opening experiment, just close and quit the function.
        if sessionInfo.userCancelled
            cleanupPsychMaster();
            closeExperiment();
            return;
        end
        
        %Initialize experiment data, this makes sure the experiment data
        %scope spans all the subfunctions.
        experimentData = struct();
        %This function handles everything for the experimental trials.
        mainExperimentLoop();
    end
    
    
    if expInfo.useKbQueue
        KbQueueRelease(expInfo.deviceIndex);
    end
    
    
    
    saveResults();
    cleanupPsychMaster();
    closeExperiment();
    
    
    
catch
    
    %JMA: Fix this to gracefully release KbQueue's on error
    %Need to do the following but we may not have expInfo in the event of an error.
    %So we will just call to release all queue's that exist.
    KbQueueRelease();
    
    disp('caught')
    errorMsg = lasterror;
    
    if exist('experimentData','var') && ~isempty(experimentData)
        saveResults();
    end
    cleanupPsychMaster();
    closeExperiment;
    psychrethrow(psychlasterror);
    
end;


%This is the main guts of psychMaster. It handles all the experimental
%control. 
%It is in it's own nested function in order to clean up the main
%code and to enable easier GUI control of trials
    function mainExperimentLoop()
        
        conditionInfo = validateConditions(conditionInfo);
        
        %This code randomizes the condition order
        
        nConditions = length(conditionInfo);
        
        if ~isfield(expInfo,'pauseInfo')
            expInfo.pauseInfo = 'Paused';
        end
        
        
       %Determine trial randomization
       %Should rename conditionList to trialList to make it more clearly
       %explanatory and consistent with makeTrialList();
       conditionList = makeTrialList(expInfo,conditionInfo);
        
        %Let's start the expeirment
        %we're going to use a while loop so we can easily add trials for
        %invalid trials.
        
        %If returnToGui is set that means it's a test trial so set we don't need to show the instructions
        %Only show the instructions if we've run a complete experiment. 
        if ~sessionInfo.returnToGui
            %Show instructions and wait for a keypress.
            DrawFormattedTextStereo(expInfo.curWindow, expInfo.instructions,'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
            Screen('Flip', expInfo.curWindow);
            KbStrokeWait();
        end
        
       
        iTrial = 1;
 
        while iTrial <=length(conditionList)
            
            validTrialList(iTrial)= true;  %initialize this index variable to keep track of bad/aborted trials
            experimentData(iTrial).validTrial = true;
            feedbackMsg = [];
            feedbackColor = [1];
            
            thisCond = conditionList(iTrial);
            
            if strcmpi(expInfo.randomizationType,'blocked')
                %In the block design lets put a message and
                %pause when blocks change
                if iTrial >1 && thisCond ~= conditionList(iTrial-1)
                    
                    %In the future add code here to enable custom block
                    %messages
                    blockMessage = 'Block Completed. Press any key to start next block';
                    DrawFormattedTextStereo(expInfo.curWindow, blockMessage,...
                        'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                    Screen('Flip', expInfo.curWindow);
                    KbStrokeWait();
                    
                end
            end
            
            %decide how to display trial depending on what type of trial it is.
            switch lower(conditionInfo(thisCond).type)
                %generic trials just fire the trial function. Everything is
                %handled there.
                case {'generic', 'simpleresponse'}
                    %ISI happens before a trial starts, this isn't a super-accurate way
                    %to create an ISI, it makes an ISI at LEAST this big.
                    WaitSecs(conditionInfo(thisCond).iti);

                    
                    [trialData] = conditionInfo(thisCond).trialFun(expInfo,conditionInfo(thisCond));
                        
                    %Now validate that this structure
                    %This checks for fields needed by the rest of the code
                    %if they don't exist they're given default values
                    trialData = validateTrialData(trialData);
                    
                    
                    %Here we'll add the response collection
                    %There is a bit of redunancy with the 2afc code.  I
                    %don't like it but it will do for now.
                    if strcmp(lower(conditionInfo(thisCond).type),'simpleresponse')
                        
                        [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                        
                        trialData.firstPress = responseData.firstPress;
                        trialData.pressed    = responseData.pressed;
                        trialData.abortNow = false;
                        trialData.validTrial = false; %Default not valid unless proven otherwise
                        
                        if trialData.firstPress(KbName('ESCAPE'))
                            %pressed escape lets abort experiment;
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            trialData.abortNow = true;
                            
                        elseif trialData.firstPress(KbName('space'))
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            DrawFormattedTextStereo(expInfo.curWindow, expInfo.pauseInfo, ...
                                'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                            Screen('Flip', expInfo.curWindow);
                            KbStrokeWait();
                            
                        else
                            trialData.validTrial = true;
                        end
                        
                        
                        
                    end
                    
                    
                    
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
                    
                    %option to make a beep before the first interval
                    if conditionInfo(thisCond).intervalBeep
                        
                        PsychPortAudio('Volume', expInfo.audioInfo.pahandle, 0.5); %the volume of the beep
                        
                        intervalBeep = MakeBeep(500, expInfo.audioInfo.beepLength, expInfo.audioInfo.samplingFreq);
                        
                        PsychPortAudio('FillBuffer', expInfo.audioInfo.pahandle, [intervalBeep; intervalBeep]);
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        WaitSecs(expInfo.audioInfo.beepLength);
                        
                        PsychPortAudio('Stop', expInfo.audioInfo.pahandle);
                        
                    end
                    
                    [trialData.firstCond] = conditionInfo(thisCond).trialFun(expInfo,firstCond);
                   
                    WaitSecs(conditionInfo(thisCond).iti);
                    
                    %option to make a beep before the second interval
                    
                    if conditionInfo(thisCond).intervalBeep
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        WaitSecs(expInfo.audioInfo.beepLength + expInfo.audioInfo.ibi);
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        WaitSecs(expInfo.audioInfo.beepLength);
                        
                        PsychPortAudio('Stop', expInfo.audioInfo.pahandle);
                        
                    end
                    
                    [trialData.secondCond] = conditionInfo(thisCond).trialFun(expInfo,secondCond);
                    
                    %Now validate that this structure
                    %This checks for fields needed by the rest of the code
                    %if they don't exist they're given default values
                    trialData = validateTrialData(trialData);
                    
                    
                    fixationInfo.fixationType = 'cross';
                    fixationInfo.responseSquare = 1;
                    fixationInfo.apetureType = 'frame';
                    
                    expInfo = drawFixation(expInfo, fixationInfo);
                    Screen('Flip', expInfo.curWindow);
                    Screen('close', expInfo.fixationTextures);
                    
                    [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                    
                    trialData.firstPress = responseData.firstPress;
                    trialData.pressed    = responseData.pressed;
                    trialData.abortNow = false;
                    
                    
                    if nullFirst
                        %the null is now always the wrong answer because it doesn't
                        %change speeds so if the null is first the correct response is j
                        correctResponse = 'j';
                        incorrectResponse = 'f';
                    else %otherwise the null is second and the correct response is f
                        correctResponse = 'f';
                        incorrectResponse = 'j';
                    end
                    
                    trialData.validTrial = false; %Default not valid unless proven otherwise
                    if trialData.firstPress(KbName('ESCAPE'))
                        %pressed escape lets abort experiment;
                        trialData.validTrial = false;
                        experimentData(iTrial).validTrial = false;
                        trialData.abortNow = true;
                        
                    elseif trialData.firstPress(KbName('space'))
                        trialData.validTrial = false;
                        experimentData(iTrial).validTrial = false;
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
                    
                case 'directionreport'
                    
                    [trialData] = conditionInfo(thisCond).trialFun(expInfo,conditionInfo(thisCond));
                    %Now validate that this structure
                    %This checks for fields needed by the rest of the code
                    %if they don't exist they're given default values
                    trialData = validateTrialData(trialData);
                    
                    
                    fixationInfo.fixationType = 'cross';
                    fixationInfo.responseSquare = 1;
                    fixationInfo.apetureType = 'frame';
                    
                    expInfo = drawFixation(expInfo, fixationInfo);
                    Screen('Flip', expInfo.curWindow);
                    Screen('close', expInfo.fixationTextures);
                    
                    [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                    
                    trialData.firstPress = responseData.firstPress;
                    trialData.pressed    = responseData.pressed;
                    trialData.abortNow = false;
                    
                    if trialData.firstPress(KbName('ESCAPE')) %same as above
                        %pressed escape lets abort experiment;
                        trialData.validTrial = false;
                        experimentData(iTrial).validTrial = false;
                        trialData.abortNow = true;
                        
                    elseif trialData.firstPress(KbName('space')) %same as above
                        trialData.validTrial = false;
                        experimentData(iTrial).validTrial = false;
                        DrawFormattedTextStereo(expInfo.curWindow, expInfo.pauseInfo, ...
                            'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                        Screen('Flip', expInfo.curWindow);
                        KbStrokeWait();
                        
                    else
                        if trialData.firstPress(KbName('1')); %left-towards response
                            experimentData(iTrial).chosenInterval = 1;
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('2'))
                            experimentData(iTrial).chosenInterval = 2; %towards response
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('3'))
                            experimentData(iTrial).chosenInterval = 3; %right-towards response
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('4'))
                            experimentData(iTrial).chosenInterval = 4; %left reponse
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('6'))
                            experimentData(iTrial).chosenInterval = 6; %right response
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('7'))
                            experimentData(iTrial).chosenInterval = 7; %left-away response
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('8'))
                            experimentData(iTrial).chosenInterval = 8; %away response
                            trialData.validTrial = true;
                        elseif trialData.firstPress(KbName('9'))
                            experimentData(iTrial).chosenInterval = 9; %right-away response
                            trialData.validTrial = true;
                        end
                    end
                    
                    
                    
            end
            
            
            experimentData(iTrial).condNumber = thisCond;
                        
            if ~trialData.validTrial  %trial not valid
                
                if trialData.abortNow
                    break;
                end
                
                %If the structure is blocked add a trial to the current
                %block.  %JMA: TEST THIS CAREFULLY. Not full vetted
                if strcmpi(expInfo.randomizationType,'blocked')
                    thisCond = conditionList(iTrial);
                    conditionList(iTrial+1:end+1) =[ thisCond conditionList(iTrial+1:end)];
                else %For other trial randomizations just add the current condition to the end.                   
                    conditionList(end+1) = conditionList(iTrial);
                end
                validTrialList(iTrial) = false;
                experimentData(iTrial).validTrial = false;
                
                fixationInfo.fixationType = '';
                fixationInfo.responseSquare = 0;
                fixationInfo.apetureType = 'frame';
                
                
                DrawFormattedTextStereo(expInfo.curWindow, 'Invalid trial','center', 'center', 1);
                
                expInfo = drawFixation(expInfo, fixationInfo);
                
                Screen('Flip', expInfo.curWindow);
                Screen('close', expInfo.fixationTextures);
                WaitSecs(.5);
                expInfo = drawFixation(expInfo, fixationInfo);
                Screen('Flip', expInfo.curWindow);
                Screen('close', expInfo.fixationTextures);
                
                %valid response made, should we give feedback?
            elseif conditionInfo(thisCond).giveFeedback
                %Give feedback:
                fixationInfo.fixationType = '';
                fixationInfo.responseSquare = 0;
                fixationInfo.apetureType = 'frame';
                
                DrawFormattedTextStereo(expInfo.curWindow, trialData.feedbackMsg,...
                    'center', 'center', feedbackColor);
                
                expInfo = drawFixation(expInfo, fixationInfo);
                
                Screen('Flip', expInfo.curWindow);
                Screen('close', expInfo.fixationTextures);
                WaitSecs(1.5);
                expInfo = drawFixation(expInfo, fixationInfo);
                Screen('Flip', expInfo.curWindow);
                Screen('close', expInfo.fixationTextures);
                
            elseif conditionInfo(thisCond).giveAudioFeedback
                
                fixationInfo.fixationType = 'cross';
                fixationInfo.responseSquare = 0;
                fixationInfo.apetureType = 'frame';
                expInfo = drawFixation(expInfo, fixationInfo);
                Screen('Flip', expInfo.curWindow);
                Screen('close', expInfo.fixationTextures);
                
                if experimentData(iTrial).isResponseCorrect;
                    
                    correctBeep = MakeBeep(750, expInfo.audioInfo.beepLength, expInfo.audioInfo.samplingFreq);
                    
                    PsychPortAudio('FillBuffer', expInfo.audioInfo.pahandle, [correctBeep; correctBeep]);
                    
                    PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                    
                    WaitSecs(expInfo.audioInfo.beepLength + expInfo.audioInfo.postFeedbackPause);
                    
                    PsychPortAudio('Stop', expInfo.audioInfo.pahandle);
                    
                else
                    
                    incorrectBeep = MakeBeep(250, expInfo.audioInfo.beepLength, expInfo.audioInfo.samplingFreq);
                    
                    PsychPortAudio('FillBuffer', expInfo.audioInfo.pahandle, [incorrectBeep; incorrectBeep]);
                    
                    PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                    
                    WaitSecs(expInfo.audioInfo.beepLength + expInfo.audioInfo.postFeedbackPause);
                    
                    PsychPortAudio('Stop', expInfo.audioInfo.pahandle);
                    
                end
                
            end
            
            
            experimentData(iTrial).trialData = trialData;
            iTrial = iTrial+1;
            
        end %End while loop for showing trials.
        
    end


%Check that expected functions are in the path.
%This is just a quick and dirty check of a couple of functions
    function pathIsCorrect = checkPath()
        %Determine if the path is setup correctly by looking for a few key files
        %Add more files here as needed
        requiredFunctionList = { 'pmGui' 'openExperiment' };
        nFunctions = length(requiredFunctionList);
        
        pathIsCorrect = true;
        for iFunction = 1:nFunctions
            
            if ~exist(requiredFunctionList{iFunction},'file')
                pathIsCorrect = false;
                break;
            end
        end
        
    end

    function setupPath()
        
        
        %find where this function is being called from. 
        thisFile = mfilename('fullpath');
        [thisDir, ~, ~] = fileparts(thisFile);
        
        %For now just grab this and all subdirectories
        newPath2Add = genpath(thisDir);

        %Note: think about adding some code to check for path issues here
        
        %Add them to the path.  
        addpath(newPath2Add);
        
    end


%This function handles saving everything about an experiment. 
    function saveResults()
        %This block saves information for the session.
        
        sessionInfo.expInfo = expInfo;
        sessionInfo.conditionInfo = conditionInfo;
        %Now get our path, and find the files used
        P = mfilename('fullpath');
        [localDir] = fileparts(P);
        [ mfiles ] = findLocalExecutedFiles( localDir );
        
        %Now loop through all the files and save them
        for iFile = 1:length(mfiles)
            [~,name] = fileparts(mfiles{iFile});
            sessionInfo.mfileBackup(iFile).name = name;
            sessionInfo.mfileBackup(iFile).content = fileread(mfiles{iFile});
        end
        
        %Now save the diary:
        sessionInfo.diary = fileread(diaryName);
        
        
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
            disp(['Creating data directory: ' datadir])
            mkdir(datadir)
        end
        
        try
            save(saveFilename,'sessionInfo','experimentData');
        catch ME
            disp('><><><><!><!><!><!><!><!><!><!><!><!><!><><><><>')
            disp('ERROR SAVING DATA')
            disp('><><><><!><!><!><!><!><!><!><!><!><!><!><><><><>')
            disp(getReport(ME))
        end
        
    end

%This is a function that handles cleaning up things specific to this file
%deleting the tempory diary.
    function cleanupPsychMaster()
        
        delete(diaryName);
    end



end
