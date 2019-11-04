function [] = ptbCorgi(sessionInfo)
%ptbCorgi  Master script that controls running experiments
%   [] = ptbCorgi()
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
%   conditionInfo defines all the conditions that will be run by ptbCorgi.
%   conditionInfo is a structure with an entry for each condtion that will be run
%
%   Mandatory fields: nReps, trialFun, iti
%   trialFun  = a function handle to the trial function
%               [ ADD MORE DOCUMENTATION HERE ]
%   nReps     = number of reptitions to run this condition
%               (each condition can have a different number).
%   iti       = The intertrial interval in seconds. Currently implemented
%               with a simple WaitSecs() call so the iti is AT LEAST this long
%
%
%   Optional fields with defaults in []:
%
%   type = ['generic'] A string that identifies what type of trial, choices:
%          'Generic'  -  The most basic trial handling. Only handles
%                        randomizing, trial presentation and saving data.
%                        The @trialFun will handle collecting responses and
%                        feedback
%          'simpleResponse' -  Like 'Generic' but waits for a response after
%                        every trial and saves it.
%          '2afc'     -  This will implement 2 temporal alternative forced
%                        choice. This option will collect responses and
%                        will optionally provide feedback (if giveFeedback
%                        and/or giveAudioFeedback is set to TRUE). 2afc can
%                        be specified in two ways. First you can provide a
%                        complete description of the target and null
%                        stimulus. The target is whatever is in the
%                        conditionInfo struct. The null is specified in the
%                        'nullCondition' field.
%
%                          nullCondition = a conditionInfo structure with a
%                                          single condition that will be
%                                          used as the comparison. It
%                                          will be passed in to the
%                                          trialFun when rendering the null
%                                          interval. 
%
%                        Another way is to let ptbCorgi generate the target
%                        and null automatically if you want to change just
%                        a single value. You do this by specifying which
%                        fieldname will change and how much to change it
%                        by. This is needed if you want to have an
%                        increment from a random value on each trial.
% 
%                          targetFieldname = string name of field
%                          targetDelta     = amount to change
%                                           (targetFieldname) by (i.e. 1,
%                                           -10)
%
%
%   label        = [''] A short string that identifies the condition
%                  e.g. 'vertical', 'Contrast: 25', or  'Target: Red'
%
%   giveFeedback = [false] Bolean whether to print feedback after trial.
%                  2AFC mode automatically sets the message. But for other
%                  modes your "trialfun" will display whatever string is in
%                  trialData.feedbackMsg
%
%   giveAudioFeedback = [false] Bolean whether to play feedback sound after trial.
%                  2AFC mode automatically sets the sound. But for other
%                  modes your "trialfun" will display whatever string is in
%                  trialData.feedbackSnd
%
%   randomizeField  - [] This option allows for randomizing an aspect of a
%                     condition on each trial. It is a structure with as
%                     many entries as fields to randomize.  For each entry
%                     the following values determine the randomization:
%                        fieldname = a string indicating which field to randomize
%                        type      = ['gaussian'] or 'uniform','custom'
%                        param     = For gaussian it is the mean and
%                                    standard deviation, For uniform it's
%                                    the upper and lower bounds. If
%                                    'custom' it is a handle to the
%                                    function to call to generate the
%                                    random value.
%
%
%
%
%   expInfo defines experiment wide settings. Mostly things that are
%   for PsychToolbox.  But also other things that are aren't specific to a
%   specific condition.  Mostly these are things that may be needed outside
%   the "trialFun". See help openExperiment for more information.
%
%   Notable expInfo fields:
%   viewingDistance   =  [57] The viewing distance in cm.
%
%   instructions      = [''] A message to display before the start of
%                      experiment
%
%   trialRandomization = [] A structure containing a description of how to
%                        randomize trials. See help MakeTrialList for a
%                        full description. Defaults to random trial order.
%                    
%
%   fixationInfo      = [] Is a structure containing the description of
%                       what to draw for the fixation marker. Check the
%                       help for drawFixation for a description.
%                       See also drawFixation

%   stereoMode        = [0] A number selecting a PTB stereomode.
%
%
%
%   ptbCorgi will loop over the different conditions in the paradigm
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

% add field showTrialNb to expInfo for showing trial numbers and wait for keyboard

%Initial setup

thisFile = mfilename('fullpath');
[thisDir, ~, ~] = fileparts(thisFile);

%Try using the "onCleanup" function to detect ctrl-C aborts
%But this doesn't work easily.
%finishup = onCleanup(@nonExpectedExit);

%Check if path is correct, if not try and fix it.
if ~checkPath()
    disp('<><><><><><> PTBCORGI <><><><><><><>')
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
%If it doesn't exist or is empty we are starting a new session.
%So we need to initialize sessionInfo.
if ~exist('sessionInfo','var') || isempty(sessionInfo)
    %  sessionInfo.participantID = input('What is the participant ID:  ','s');
    %store the date. use: datestr(sessionInfo.sessionDate) to make human readable
    sessionInfo.sessionDate = now;
    sessionInfo.sessionDateHuman = datestr(sessionInfo.sessionDate,'YYYY-MM-DD hh:mm PM');
    sessionInfo.ptbCorgiVer = ptbCorgiVersion();
    sessionInfo.participantID = 'null';
    sessionInfo.tag           = '';
    [~,ptbVerStruct]=PsychtoolboxVersion;
    sessionInfo.ptbVersion = ptbVerStruct;
    
    %Matlab older random number code is flawed.  It has been updated but
    %lot's of code exists that still uses the "legacy random number
    %generators" and syntax "discouraged" by mathworks.
    %See: https://uk.mathworks.com/help/matlab/math/updating-your-random-number-generator-syntax.html
    %Therefore, I'm turning on warnings that help users identify when they
    %use the discouraged methods.
    warning('on','MATLAB:RandStream:ActivatingLegacyGenerators');
    warning('on','MATLAB:RandStream:ReadingInactiveLegacyGeneratorState');
    %Need to reset the rng before shuffling in case the legacy RNG has
    %activated before we started ptbCorgi. Deactivate the legacy system
    %and use the modern system.
    rng('default');
    rng('shuffle');
    %Technically not a "seed".
    sessionInfo.randomSeed = rng;
    
    
    %Initialize this variable to false to catch when sessions exit early.
    sessionInfo.sessionCompleted = false;
end

%Initialize variables here so we can access them in the subfunctions.

expInfo     = struct();
initConditionInfo = struct();


%Check if we should migrate old psychMaster settings to ptbCorgi
if ~isempty(getpref('psychMaster')) && isempty(getpref('ptbCorgi'))
    disp('Migrating old psychMaster preferences to ptbCorgi')
    pmPref = getpref('psychMaster');
    pmPrefList = fieldnames(pmPref);
    
    for iPref = 1:length(pmPrefList),
        setpref('ptbCorgi',pmPrefList{iPref},pmPref.(pmPrefList{iPref}))
    end
    
    
end

%Check for preferences.  Preferences enable  easy configuration changes for
%different machines without having to hardcode things.
%right now this just has some examples for setting per machine paths

base = '';
datadir = '';

if ~isempty(getpref('ptbCorgi'))
    
    if ispref('ptbCorgi','base')
        base = getpref('ptbCorgi','base');    
    end        
    
    if ispref('ptbCorgi','datadir')
        datadir = getpref('ptbCorgi','datadir');   
    end
    
    
    
else
    
    disp('!!Please run the folowing command to define defaults:');
    disp('ptbCorgiSetup ');
end


if isempty(base) || ~exist(datadir,'dir')
    pathToPM = which('ptbCorgi');
    [base] = fileparts(pathToPM);
    setpref('ptbCorgi','base',base);
    disp(['Setting ptbCorgi directory preference to: ' pwd]);
else
    disp(['Setting ptbCorgi home directory: ' base]);
end

if isempty(datadir) || ~exist(datadir,'dir'),
    setpref('ptbCorgi','datadir',fullfile(base,'Data'));
    disp(['Setting ptbCorgi data directory preference to: ' fullfile(base,'Data')]);
else
    disp(['Saving data to: ' datadir]);
end

disp('Use ptbCorgiSetup() to redefine defaults');

    
  
    
    sessionInfo.gitHash = ptbCorgiGitHash();
    
    %Note: Any field added to expInfo before pmGui() is called will be used
    %when opening a paradigm from a session file.  If you don't want these
    %fields used look in ptbCorgiLoadParadigm() and add the field to the
    %fieldsToRemove{} list.
    expInfo = struct();
    
    %loop to enable firing single conditions for testing, could also be
    %extended to multiple blocks in the future.
    [sessionInfo,expInfo,conditionInfo] = pmGui(sessionInfo,expInfo);
    drawnow; %<- required to actually close the gui.
    
    %User canceled before opening experiment, just quit the function.
    if sessionInfo.userCancelled
        cleanupPtbCorgi();
        return;
    end
    
    %If any conditions request audiofeedback that forces enabling audio.
    %If any conditions request interval beeps played that forces audio
    %Add any other checks for things that require audio here
    if  any( [conditionInfo(:).giveAudioFeedback]) ...
            || (isfield(conditionInfo,'intervalBeep') && any([conditionInfo(:).intervalBeep]))        
        
        if isfield(expInfo,'enableAudio') && ~expInfo.enableAudio
            warning('ptbCorgi:ptbCorgi:audioForced',...
                'User requested disabling audio, however conditionInfo requested providing audio feedback. Forcing audio to be enabled');
        end
        expInfo.enableAudio = true;        
    end
    
    sessionInfo.expInfoBeforeOpenExperiment = expInfo;
    
    %Now lets begin the experiment and loop over the conditions to show.
    expInfo = openExperiment(expInfo);
    %If we're running full screen lets hide the mouse cursor from view.
    %Need to do this here for different OS versions and to enable
    %control from pmGui
    if expInfo.useFullScreen == true
        HideCursor(expInfo.screenNum);
    end
    
    
    %Initialize experiment data, this makes sure the experiment data
    %scope spans all the subfunctions.
    experimentData = struct();
    %This function handles everything for the experimental trials.    
    mainExperimentLoop();
    
    %If returnToGui is TRUE we ran a test trial and want the gui to pop-up
    while sessionInfo.returnToGui
        
        
        %If using full screen mode on single monitor make sure to
        %close the ptb window after a test, otherwise we can get stuck. 
        if length(Screen('Screens'))==1 && expInfo.useFullScreen
            closeExperiment;
        end
        
        [sessionInfo,expInfo,conditionInfo] = pmGui(sessionInfo,expInfo,sessionInfo.backupConditionInfo);
        drawnow; %<- required to actually close the gui.
        
        %User canceled after opening experiment, just close and quit the function.
        if sessionInfo.userCancelled
            cleanupPtbCorgi();
            closeExperiment();
            return;
        end
        
        %Check if we crashed Screen and if so re-open the
        %window.
        if isempty(Screen('Windows'))
            expInfo = openExperiment(sessionInfo.expInfoBeforeOpenExperiment);
        end
        
        %Initialize experiment data, this makes sure the experiment data
        %scope spans all the subfunctions.
        experimentData = struct();
        %If we're running full screen lets hide the mouse cursor from view.
        %Need to do this here for different OS versions and to enable
        %control from pmGui
        if expInfo.useFullScreen == true
            HideCursor(expInfo.screenNum);
        end
        %This function handles everything for the experimental trials.
        mainExperimentLoop();
    end
    
    
    if expInfo.useKbQueue
        KbQueueRelease();
    end
    
    
    sessionInfo.sessionCompleted = true;
    saveResults();
    closeExperiment();
    cleanupPtbCorgi();
    
    



%This is the main guts of ptbCorgi. It handles all the experimental
%control.
%It is in it's own nested function in order to clean up the main
%code and to enable easier GUI control of trials
    function mainExperimentLoop()
        
        try
        conditionInfo = validateConditions(expInfo,conditionInfo);
        
        %Contains the information in conditionInfo before trials start that
        %could potentially change values.
        initConditionInfo = conditionInfo;
        
        nConditions = length(conditionInfo);
        
        if ~isfield(expInfo,'pauseInfo')
            expInfo.pauseInfo = 'Paused';
        end
        
        
        %Determine trial randomization
        %Should rename conditionList to trialList to make it more clearly
        %explanatory and consistent with makeTrialList();
        [conditionList, blockList] = makeTrialList(expInfo,conditionInfo);
        
        %Let's start the expeirment
        %we're going to use a while loop so we can easily add trials for
        %invalid trials.
        
        ptbCorgiSendTrigger(expInfo,'clear',true);%First clear DIO status.
        ptbCorgiSendTrigger(expInfo,'startRecording',true);%Now trigger recording start
        
        
        %If returnToGui is set that means it's a test trial so set we don't need to show the instructions
        %Only show the instructions if we're running a complete experiment
        %and the instructions are not empty.
        if ~sessionInfo.returnToGui && ~isempty(expInfo.instructions)

            %Show instructions and wait for a keypress.
            DrawFormattedTextStereo(expInfo.curWindow, expInfo.instructions,'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
            Screen('Flip', expInfo.curWindow);
            KbStrokeWait();
            
        end
        
        
        iTrial = 1;
  
        expInfo = drawFixation(expInfo, expInfo.fixationInfo);
        Screen('Flip', expInfo.curWindow);
        
        while iTrial <=length(conditionList)
            
            fprintf('trial %d / %d \n', iTrial, length(conditionList))
            
            %Adding some info about the current trial to expInfo. This is so
            %trialFun functions can use it.
            expInfo.currentTrial.number = iTrial;
            
            validTrialList(iTrial)= true;  %initialize this index variable to keep track of bad/aborted trials
            experimentData(iTrial).validTrial = true;
            feedbackMsg = [];
            feedbackColor = [1];
            
            thisCond = conditionList(iTrial);
            thisBlock = blockList(iTrial);
            experimentData(iTrial).blockNumber = thisBlock;

            %Send a trigger now indicating the condition number for
            %upcoming trial.
            
            %Check if we're are running a test condition then there is only
            %one condition in the condition field and the true condition number
            %is put into the testCondTrueNum field. That's the number we
            %want to signal on the trigger port.  
            if isfield(conditionInfo(1),'testCondTrueNum')
                condToSend = conditionInfo(1).testCondTrueNum;
                thisCond = 1;
            else
                condToSend = thisCond;
            end
            ptbCorgiSendTrigger(expInfo,'conditionNumber',true,condToSend);%
            
            %Handle randomizing condition fields
            %This changes the conditionInfo structure so is a bit of a
            %danger. Well it's a very big danger. But it's the easiest way
            %to implement changing things on the fly.
            conditionInfo(thisCond) = randomizeConditionField(conditionInfo(thisCond));
            
            
            if strcmpi(expInfo.trialRandomization.type,'blocked') || strcmpi(expInfo.trialRandomization.type,'custom')
                %In the block design lets put a message and
                %pause when blocks change
                if iTrial >1 && thisBlock ~= blockList(iTrial-1)
                    
                    %In the future add code here to enable custom block
                    %messages
                    blockMessage = ['Block ' num2str(blockList(iTrial-1)) '/' num2str(max(blockList)) ' completed. Press any key to start'];
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
                    %There is a bit of redunancy with the [-90,90,-90,90] code.  I
                    %don't like it but it will do for now.
                    if strcmpi(conditionInfo(thisCond).type,'simpleresponse')
                        
                        [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                        
                        trialData.firstPress = responseData.firstPress;
                        trialData.pressed    = responseData.pressed;
                        trialData.abortNow = false;
                        trialData.validTrial = false; %Default not valid unless proven otherwise
                        validKeyIndices = []; %For user set valid keys.
                        
                        
                        
                        %If user has set 'validKeyNames' and it is not empty
                        %Could put this in the if/elseif below, but I think
                        %putting it here makes the code more clear below
                        if isfield(conditionInfo(thisCond), 'validKeyNames') ...
                                && ~isempty(conditionInfo(thisCond).validKeyNames)
                            %KbName will return a list of key indices if it is
                            %given a cell array of keynames
                            validKeyIndices = KbName(conditionInfo(thisCond).validKeyNames);
                            
                        end
                        
                        %Now let's do some response parsing
                        
                        %1st check if user defined valid keys and any of
                        %them were pressed.
                        numberOfKeysPressed = length(find(trialData.firstPress));
                        
                        if numberOfKeysPressed > 1 %If more than one key is pressed trial is not valid 
                            
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            experimentData(iTrial).response = KbName(trialData.firstPress);
                        
                        elseif ~isempty(validKeyIndices) ...
                                && any( trialData.firstPress( validKeyIndices) )
                            trialData.validTrial = true;
                            experimentData(iTrial).validTrial = true;
                            experimentData(iTrial).response = KbName(trialData.firstPress);
                            
                            %If the user hasn't defined valid keys or the particpant hasn't pressed let's decide what to do.
                            %'Space' comes next because it allows defining
                            %'space' as a valid key and collected data from it'
                            %If space hasn't been defined as a 'validKeyName'
                            %above let's use it to pause.
                        elseif trialData.firstPress(KbName('space'))
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            experimentData(iTrial).response = [];
                            
                            DrawFormattedTextStereo(expInfo.curWindow, expInfo.pauseInfo, ...
                                'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                            Screen('Flip', expInfo.curWindow);
                            KbStrokeWait();
                            
                            %If there's no user defined valid keys, and we
                            %haven't caught a 'space' above count any other
                            %keypress as valid trial or 'space has been
                            %pressed.
                        elseif isempty(validKeyIndices) && any(trialData.firstPress)
                            trialData.validTrial = true;
                            experimentData(iTrial).validTrial = true;
                            experimentData(iTrial).response = KbName(trialData.firstPress);
                            %Nothing caught above so it's not a valid trial.
                            %Not strictly neccessary, but here for clarity.
                        else
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            experimentData(iTrial).response = [];
                        end
                        
                        %No matter what is parsed above. If 'ESCAPE' is pressed
                        %always abort
                        if trialData.firstPress(KbName('ESCAPE'))
                            %pressed escape lets abort experiment;
                            trialData.validTrial = false;
                            experimentData(iTrial).validTrial = false;
                            trialData.abortNow = true;
                        end
                        

                       
                        %if user set a correct key let's decide what to do
                        if ~isempty(conditionInfo(thisCond).correctKey)
                            
                            %If any of the correct keys were pressed
                            if any(strcmp(experimentData(iTrial).response, conditionInfo(thisCond).correctKey))
                                
                                %Having two lines for isResponseCorrect is STUPID: JMA
                                %FIX ASAP.                                
                                experimentData(iTrial).isResponseCorrect = true;
                                trialData.isResponseCorrect = true;                                
                                %feedbackMsg doesn't need an if because it
                                %is always set in trialData. 
                                trialData.feedbackMsg = 'Correct';%Consider making this setable by conditionInfo
                                %Enclosed audio feedback in an if check because
                                %expInfo.audioInfo does not exist if audio
                                %is not enabled. 
                                if conditionInfo(thisCond).giveAudioFeedback                                     
                                    trialData.audioFeedbackSnd  = expInfo.audioInfo.correctSnd;                                 
                                end                                
                                
                            else %No correct keys were pressed
                                
                                %Having two lines for isResponseCorrect is STUPID: JMA
                                %FIX ASAP. 
                                experimentData(iTrial).isResponseCorrect = false;
                                trialData.isResponseCorrect = false;                                
                                trialData.feedbackMsg = 'Incorrect'; %Consider making this setable by conditionInfo
                                if conditionInfo(thisCond).giveAudioFeedback
                                    trialData.audioFeedbackSnd  = expInfo.audioInfo.incorrectSnd;                                    
                                end
                                
                            end
                        
                        end
                    end
                    
                    
                    
                case '2afc'
                    %TODO: Add correctKey specification ala simpleResponse
                    %above. 
                    %Which trial first?
                    
                    nullFirst = rand()>.5;
                    
                    %If targetFieldname is set use this to setup the
                    %condition values.
                    if ~isempty(conditionInfo(thisCond).targetFieldname);
                        conditionInfo(thisCond).nullCondition = conditionInfo(thisCond);
                        fieldname = conditionInfo(thisCond).targetFieldname;
                        delta     = conditionInfo(thisCond).targetDelta;
                        conditionInfo(thisCond).(fieldname) = conditionInfo(thisCond).(fieldname) +delta;
                        
                        experimentData(iTrial).targetFieldname = fieldname;
                        experimentData(iTrial).targetValue = conditionInfo(thisCond).(fieldname);
                        experimentData(iTrial).nullValue = conditionInfo(thisCond).nullCondition.(fieldname);
                        experimentData(iTrial).targetDelta = delta;
                    end
                    
                    
                    if nullFirst
                        firstCond = conditionInfo(thisCond).nullCondition;
                        secondCond = conditionInfo(thisCond);
                    else
                        firstCond = conditionInfo(thisCond);
                        secondCond = conditionInfo(thisCond).nullCondition;
                    end
                    
                    trialData.nullFirst = nullFirst;
                    expInfo.currentTrial.nullFirst = nullFirst;
                    
                    %option to make a beep before the first interval
                    if conditionInfo(thisCond).intervalBeep
                        
                        PsychPortAudio('Volume', expInfo.audioInfo.pahandle, 0.5); %the volume of the beep
                        
                        PsychPortAudio('FillBuffer', expInfo.audioInfo.pahandle, expInfo.audioInfo.intervalBeep);
                        
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        %WaitSecs(expInfo.audioInfo.beepLength);
                        
                        PsychPortAudio('Stop', expInfo.audioInfo.pahandle,1);
                        %PsychPortAudio('Stop', expInfo.audioInfo.pahandle);
                        
                    end
                    
                    %For nAFC type trials keep track of which one is being
                    %shown now for the @trialFun
                    expInfo.currentTrial.iAfc = 1;
                    
                    [trialData.firstCond] = conditionInfo(thisCond).trialFun(expInfo,firstCond);
                    expInfo.currentTrial.trialData = trialData;
                    
                    expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                    Screen('Flip', expInfo.curWindow);
                    WaitSecs(conditionInfo(thisCond).iti);
                    
                    %option to make a beep before the second interval
                    
                    if conditionInfo(thisCond).intervalBeep
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        WaitSecs(expInfo.audioInfo.beepLength + expInfo.audioInfo.ibi);
                        
                        PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                        
                        % WaitSecs(expInfo.audioInfo.beepLength+1);
                        
                        PsychPortAudio('Stop', expInfo.audioInfo.pahandle,1);
                        
                    end
                    
                    
                    %For nAFC type trials keep track of which one is being
                    %shown now for the @trialFun
                    expInfo.currentTrial.iAfc = 2;
                    [trialData.secondCond] = conditionInfo(thisCond).trialFun(expInfo,secondCond);
                    
                    %Now validate that this structure
                    %This checks for fields needed by the rest of the code
                    %if they don't exist they're given default values
                    trialData = validateTrialData(trialData);
                    
                    expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                    responseMarker.type = 'square';
                    expInfo = drawFixation(expInfo, responseMarker);
                    
                    Screen('Flip', expInfo.curWindow);
                    
                    [responseData] = getResponse(expInfo,conditionInfo(thisCond).responseDuration);
                    
                    trialData.firstPress = responseData.firstPress;
                    trialData.pressed    = responseData.pressed;
                    trialData.abortNow = false;
                    
                    
                    if nullFirst
                        %the null is now always the wrong answer
                        %so if the null is first the correct response is j
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
                            trialData.isResponseCorrect = true;
                            trialData.validTrial = true;                            
                            trialData.feedbackMsg = 'Correct';
                            if conditionInfo(thisCond).giveAudioFeedback
                               trialData.audioFeedbackSnd  = expInfo.audioInfo.correctSnd;
                            end
                            
                        elseif trialData.firstPress(KbName(incorrectResponse))
                            experimentData(iTrial).isResponseCorrect = false;
                            trialData.isResponseCorrect = false;
                            trialData.validTrial = true;
                            trialData.feedbackMsg = 'Incorrect';
                            if conditionInfo(thisCond).giveAudioFeedback
                                trialData.audioFeedbackSnd  = expInfo.audioInfo.incorrectSnd;
                            end
                        end
                    end
                    
                case 'directionreport'
                    
                    [trialData] = conditionInfo(thisCond).trialFun(expInfo,conditionInfo(thisCond));
                    %Now validate that this structure
                    %This checks for fields needed by the rest of the code
                    %if they don't exist they're given default values
                    trialData = validateTrialData(trialData);
                    
                    
                    expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                    responseMarker.type = 'square';
                    expInfo = drawFixation(expInfo, responseMarker);
                    
                    Screen('Flip', expInfo.curWindow);
                    
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
            experimentData(iTrial).condInfo = conditionInfo(thisCond);
            
            
            if ~trialData.validTrial  %trial not valid
                
                if isfield(trialData,'abortNow') && trialData.abortNow
                    break;
                end
                
                %If the structure is blocked add a trial to the current
                %block.  %JMA: TEST THIS CAREFULLY. Not full vetted
                if strcmpi(expInfo.trialRandomization.type,'blocked')
                    thisCond = conditionList(iTrial);
                    thisBlock = blockList(iTrial);
                    
                    %Find the end of this block
                    blockEndIdx = max(find(blockList==thisBlock));
                    
                    %Add the condition to just after the end of the block
                    %(blockEndIdx+1)
                    conditionList(blockEndIdx+1:end+1) =[ thisCond conditionList(blockEndIdx+1:end)];
                    blockList(blockEndIdx+1:end+1)     =[ thisBlock blockList(blockEndIdx+1:end)];
                    
                else %For other trial randomizations just add the current condition to the end, and extend blockList
                    conditionList(end+1) = conditionList(iTrial);
                    blockList(end+1)     = 1;
                end
                validTrialList(iTrial) = false;
                experimentData(iTrial).validTrial = false;
                
                expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                
                if expInfo.stereoMode == 0;
                    expInfo.backRect = [0, 0, expInfo.windowSizePixels(1), expInfo.windowSizePixels(2)];
                    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                    DrawFormattedTextStereo(expInfo.curWindow, 'Invalid trial',...
                        'center', 'center', 1);
                else %if a stereo mode blank out everything but the noise frame.
                    
                    %look for a noise frame element in the fixation
                    frameIndex = find(strcmpi( {expInfo.fixationInfo.type},'noiseframe'),1,'first');
                    
                    if isempty(frameIndex)
                        frameSizeDeg = 0;
                    elseif  ~isfield(expInfo.fixationInfo(frameIndex),'size') ...
                            || isempty(expInfo.fixationInfo(frameIndex).size)
                        frameSizeDeg = 100/expInfo.ppd;
                    else
                        frameSizeDeg = expInfo.fixationInfo(frameIndex).size;
                    end
                    
                    frameSizePix = frameSizeDeg*expInfo.ppd;
                    
                    expInfo.backRect = [frameSizePix, ...
                        frameSizePix, ...
                        expInfo.windowSizePixels(1) - frameSizePix, ...
                        expInfo.windowSizePixels(2) - frameSizePix];
                    
                    backRect = [expInfo.backRect];
                    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
                    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                    Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
                    Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                    DrawFormattedTextStereo(expInfo.curWindow, 'Invalid trial',...
                        'center', 'center', 1);
                end
                
                Screen('Flip', expInfo.curWindow);
                WaitSecs(.5);
                
                
                expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                Screen('Flip', expInfo.curWindow);
                
                %valid response made, should we give audio or written feedback?
            elseif conditionInfo(thisCond).giveFeedback ...
                    || conditionInfo(thisCond).giveAudioFeedback
                
                experimentData(iTrial).feedbackGiven = trialData.feedbackMsg;   
                
                %Draw up the fixation.
                expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                
                %Draw written feedback if we're giving it.
                if conditionInfo(thisCond).giveFeedback
                    
                    if expInfo.stereoMode == 0;
                        expInfo.backRect = [0, 0, expInfo.windowSizePixels(1), expInfo.windowSizePixels(2)];
                        Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                        DrawFormattedTextStereo(expInfo.curWindow, trialData.feedbackMsg,...
                            'center', 'center', feedbackColor);
                    else %if a stereo mode blank out everything but the noise frame.
                        
                        %See if we are drawing a noise frame;
                        frameIndex = find(strcmpi( {expInfo.fixationInfo.type},'noiseframe'),1,'first');
                        
                        if isempty(frameIndex)
                            frameSizeDeg = 0;
                        elseif ~isfield(expInfo.fixationInfo(frameIndex),'size') ...
                                || isempty(expInfo.fixationInfo(frameIndex).size)
                            frameSizeDeg = 100/expInfo.ppd;
                        else
                            frameSizeDeg = expInfo.fixationInfo(frameIndex).size;
                        end
                        frameSizePix = frameSizeDeg*expInfo.ppd;
                        expInfo.backRect = [frameSizePix, ...
                            frameSizePix, ...
                            expInfo.windowSizePixels(1) - frameSizePix, ...
                            expInfo.windowSizePixels(2) - frameSizePix];
                        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
                        Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
                        Screen('FillRect', expInfo.curWindow, expInfo.bckgnd, expInfo.backRect);
                        DrawFormattedTextStereo(expInfo.curWindow, trialData.feedbackMsg,...
                            'center', 'center', feedbackColor);
                    end
                end %closes: if conditionInfo(thisCond).giveFeedback
                
                %Start the audiofeedback right before the flip so it's
                %roughly coincident with the written feedback.
                if conditionInfo(thisCond).giveAudioFeedback
                    
                    PsychPortAudio('FillBuffer', expInfo.audioInfo.pahandle, trialData.audioFeedbackSnd);
                    PsychPortAudio('Start', expInfo.audioInfo.pahandle, expInfo.audioInfo.nReps, expInfo.audioInfo.startCue);
                    %  PsychPortAudio('Stop', expInfo.audioInfo.pahandle,1);
                end
                
                
                Screen('Flip', expInfo.curWindow);
                %Show feedback for 1.5 seconds
                %JMA- Consider making this a tunable parameter.
                if isfield(expInfo,'durationFeedback')
                   WaitSecs(expInfo.durationFeedback);                 
                else
                    WaitSecs(1.5);
                end
                
                
            end %closes: elseif conditionInfo(thisCond).giveFeedbac
            
            if isfield(expInfo,'showTrialNb') == 0
                expInfo = drawFixation(expInfo, expInfo.fixationInfo);
                Screen('Flip', expInfo.curWindow);
            else
                blockMessage = ['Trial ' num2str(iTrial) '/' num2str(length(conditionList)) ' completed. Press any key to continue'];
                DrawFormattedTextStereo(expInfo.curWindow, blockMessage,...
                    'left', 'center', 1,[],[],[],[],[],expInfo.screenRect);
                Screen('Flip', expInfo.curWindow);
                KbStrokeWait();
            end
           
            experimentData(iTrial).trialData = trialData;
            iTrial = iTrial+1;
            
        end %End while loop for showing trials.
        
     
            
        catch exception
            
            
            %If we're running a test condition return to the gui without
            %saving. This enables us to quickly debug code.
            if sessionInfo.returnToGui
               
                %If using full screen mode on single monitor make sure to
                %close the ptb window.
                if length(Screen('Screens'))==1 && expInfo.useFullScreen
                    closeExperiment;                  
                end
                
                message = getReport(exception); %Get formated report
                fprintf(2,message); %Display the error. Trick way to make text red is to use STDERR: 2.
                return;
                                
            end
            %JMA: Fix this to gracefully release KbQueue's on error
            %Need to do the following but we may not have expInfo in the event of an error.
            %So we will just call to release all queue's that exist.
            KbQueueRelease();
            
            if exist('experimentData','var') && ~isempty(experimentData)
                disp('Attempting to save data')
                sessionInfo.exception = exception;
                sessionInfo.report = getReport(exception);
                sessionInfo.psychlasterror = psychlasterror;
                sessionInfo.sessionCompleted = false;
                saveResults();
            end
            
            
            closeExperiment;
            cleanupPtbCorgi();
            disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
            disp('!!!!!   Experiment Shutdown Due to Error          !!!!!!!!')
            rethrow(exception);
            %psychrethrow(psychlasterror);
        end
        
    end


%Check that expected functions are in the path.
%This is just a quick and dirty check of a couple of functions
%This also checks to see if all subfolders are included in the path.
    function pathIsCorrect = checkPath()
        %Determine if the path is setup correctly by looking for a few key files
        %Add more files here as needed
        requiredFunctionList = { 'pmGui' 'openExperiment' };
        nFunctions = length(requiredFunctionList);
        
        pathIsCorrect = true;
        for iFunction = 1:nFunctions
            
            %If we can't find the required functions somethings wrong.
            if ~exist(requiredFunctionList{iFunction},'file')
                pathIsCorrect = false;
                return;
            end
            
            %If the required functions are "shadowed" something is fatally
            %wrong and needs to be fixed by the user.
            fileLocations = which(requiredFunctionList{iFunction},'-all');
            if length(fileLocations) >1
                disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
                disp('!!!!!   Shadowed  Functions Detected                            !!!')
                disp('!!!!!   The error message below will list the specific file     !!!')
                disp('!!!!!   Cut/paste following command to list all problem files.  !!!')
                disp('!!!!!   Then update your path to have only one copy             !!!')
                disp('[shadowFilesExistFlag, fileList] = checkForShadowedFiles()')
                error('ptbCorgi:ptbCorgi:shadowedFiles', ...
                    'Function %s is shadowed on the matlab path',...
                    requiredFunctionList{iFunction});
            end
            
            
        end
        
        %Let's make sure all sub directories are on the path.  This should
        %detect any directory changes. Which have been happening frequently
        %when changing git branches.
        %Why not just add all sub directories to the path and let matlab
        %auto prune redundancies? Well, that always brings things to the
        %top of the path. Which _may_ not be wanted from the user.
        thisFile = mfilename('fullpath');
        [thisDir, ~, ~] = fileparts(thisFile);
        
        %For now just grab the directory including ptbCorgi and all subdirectories
        %We do this in a slightly tricky way, generate a path which turns a
        %a long string with directorys separated by pathsep(). So we use a
        %regular experession to split the string based on the pathsep()
        %character
        allSubDirs = genpath(thisDir);
        subDirCell = regexp(allSubDirs, pathsep, 'split');
        pathCell = regexp(path, pathsep, 'split');
        
        for iSub = 1:length(subDirCell)
            
            thisFolder = subDirCell{iSub};
            
            %If thisFolder doesn't match any of the directories on the path
            %we're not correct.
            if ~isempty(thisFolder) && ~any(strcmp(thisFolder, pathCell));
                pathIsCorrect = false;
                return;
            end
            
        end
        
        
        
    end

    function setupPath()
        
        
        %find where this function is being called from.
        thisFile = mfilename('fullpath');
        [thisDir, ~, ~] = fileparts(thisFile);
        
        %For now just grab this and all subdirectories
        newPath2Add = genpath(thisDir);
        
        %Now let's find the directories that are missing and add only them
        %to the path.
        %Why not just add all sub directories to the path and let matlab
        %auto prune redundancies? Well, that always brings the added
        %directoreis top of the path. Which _may_ not be wanted from the
        %user.
        subDirCell = regexp(newPath2Add, pathsep, 'split');
        pathCell = regexp(path, pathsep, 'split');
        
        for iSub = 1:length(subDirCell)
            
            thisFolder = subDirCell{iSub};
            
            %If thisFolder doesn't match any of the directories on the path
            %add it to the path.
            if  ~any(strcmp(thisFolder, pathCell));
                msg = sprintf('Adding to path: %s',thisFolder);
                disp(msg);
                addpath(thisFolder);
                
            end
            
        end
        
    end


%This function handles saving everything about an experiment.
    function saveResults()
        %This block saves information for the session.
        
        %Get the final state of the window to know if anything changes from
        %starting the experiment and update the missed flip counters.
        expInfo.finalWindowInfo = Screen('GetWindowInfo', expInfo.curWindow);
        
        sessionInfo.expInfo = expInfo;
        sessionInfo.conditionInfo = initConditionInfo;
        sessionInfo.condInfoAfterExperimentFinished = conditionInfo;
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
        
        diary OFF
        %Now save the diary:
        sessionInfo.diary = fileread(diaryName);
        
        
        if isfield(expInfo,'paradigmName') && ~isempty(expInfo.paradigmName),
            filePrefix = expInfo.paradigmName;
        else
            filePrefix = func2str(sessionInfo.paradigmFun);
        end
        
        filename = [ filePrefix '_' ...
            sessionInfo.participantID '_' sessionInfo.tag '_' ...
            datestr(now,'yyyymmdd_HHMMSS') '.mat'];
        
        if ispref('ptbCorgi','datadir');
            datadir = getpref('ptbCorgi','datadir');
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


    function cleanupPtbCorgi()
        
        delete(diaryName);
    end



end
