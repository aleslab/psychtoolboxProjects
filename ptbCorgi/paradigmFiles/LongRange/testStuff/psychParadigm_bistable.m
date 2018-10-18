function [conditionInfo, expInfo] = psychParadigm_bistable(expInfo)
% present multiple stim flashed at 2 locations
% bistable percept?? 
% figured that changing the distance between the 2 locations is affecting
% the percept the most so changed the prog to test different xMotion


KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DC_rating';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'xloc'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 9; 

expInfo.viewingDistance = 57;

% expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'FIXATE the dot';

%% General conditions
conditionInfo(1).iti = 0.5; % inter-trial-interval
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 999; % next trial starts only after giving an answer % max time to answer
conditionInfo(1).nbStim = 8;
conditionInfo(1).intX = 4; % space interval between all the stimuli
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 0.5 3]; % in deg
conditionInfo(1).xloc = -10; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 3; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_bistable;
conditionInfo(1).trialDuration = 4*6*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
 % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
conditionInfo(1).dutyCycle = 7/8; %[1 2 4 6 7];



%% experimental manipulation

condNb = 1;

% single stim condition
testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
xMotion = [0.8 1.2 1.6];

% same parameters in all conditions
for cc=2:length(testedFreq)*length(xMotion)
    conditionInfo(cc) = conditionInfo(1);
end


% for mot=0:1
for testFq=1:length(testedFreq)
    for tt = 1:length(xMotion)
        conditionInfo(condNb).motion = 1;
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
        conditionInfo(condNb).xMotion = xMotion(tt);
        conditionInfo(condNb).label = [num2str(round(testedFreq(testFq))) 'Hz ' num2str(round(xMotion(tt))) '%'];
%         conditionInfo(condNb).label = [num2str(mot) 'mot' num2str(testedFreq(testFq),'%.1f') 'Hz ' num2str(onTime(tt)/8*100,'%.1f') '%'];
        condNb = condNb+1;
    end
end
% end

% for testFq=1:length(testedFreq)
%     for tt = 1:length(onTime)
%         conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
%         conditionInfo(condNb).dutyCycle = onTime(tt)/8;
%         conditionInfo(condNb).label = [num2str(testedFreq(testFq),'%.1f') 'Hz ' num2str(onTime(tt)/8*100,'%.1f') '%'];
%         condNb = condNb+1;
%     end
% end
% 
% testedFreq = [85/32 85/16 85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
% onTime = [1 2 4 6 7];
% for tt = 1:length(testedFreq)
%     conditionInfo(condNb).stimTagFreq = testedFreq(tt);
%     conditionInfo(condNb).dutyCycle = onTime(tt)/8;
%     conditionInfo(condNb).motion = 1;
%     conditionInfo(condNb).label = ['motion ' num2str(testedFreq(tt),'%.1f') 'Hz ' num2str(onTime(tt)/8*100,'%.1f') '% DC'];
%     condNb = condNb+1;
% end
% 
% % other 50/50
% conditionInfo(condNb).stimTagFreq = 85/32;
% conditionInfo(condNb).dutyCycle = 4/8;
% conditionInfo(condNb).motion = 1;
% conditionInfo(condNb).label = ['motion ' num2str(85/32,'%.1f') 'Hz 50% DC'];
% condNb = condNb+1;
% conditionInfo(condNb).stimTagFreq = 85/16;
% conditionInfo(condNb).dutyCycle = 4/8;
% conditionInfo(condNb).motion = 1;
% conditionInfo(condNb).label = ['motion ' num2str(85/16,'%.1f') 'Hz 50% DC'];


end

