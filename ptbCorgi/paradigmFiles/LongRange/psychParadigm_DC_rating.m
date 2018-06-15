function [conditionInfo, expInfo] = psychParadigm_DC_rating(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DC_rating';
expInfo.trialRandomization.type = 'custom';

expInfo.nbBlock = 7;
condition = [];
for blk=1:expInfo.nbBlock
    condList = Shuffle([repmat(1:22,1,2) 23:44]);
    new = [condList ;repmat(blk,1,length(condList))];
    condition = [condition; new'];
end
expInfo.trialRandomization.blockByField = 'blockList'; 
expInfo.trialRandomization.trialList = condition(:,1);
expInfo.trialRandomization.blockList =  condition(:,2);
% expInfo.trialRandomization.nBlockReps   = 2; 



expInfo.viewingDistance = 57;

expInfo.useBitsSharp = true;
% expInfo.enableTriggers = true;
% expInfo.useBitsSharp = false; 
expInfo.enableTriggers = false;

%Setup a simple fixation cross. See help drawFixation for more info on how
%to setup this field.
expInfo.fixationInfo(1).type  = 'cross';
expInfo.fixationInfo(1).size  = .2;
expInfo.fixationInfo(1).lineWidthPix = 2;
expInfo.fixationInfo(1).color = 0;

expInfo.instructions = 'Rate the strenght of motion';

%% General conditions
conditionInfo(1).iti = 0.5; % inter-trial-interval
conditionInfo(1).nReps = 1; 
conditionInfo(1).type = 'Generic';
conditionInfo(1).giveFeedback = 0;
conditionInfo(1).giveAudioFeedback = 0;
conditionInfo(1).intervalBeep = 0;
conditionInfo(1).maxToAnswer = 999; % next trial starts only after giving an answer % max time to answer
% conditionInfo(1).randomizeField = 'false';

%% stimulus
conditionInfo(1).stimSize = [0 0 0.5 20]; % in deg
conditionInfo(1).xloc = 3; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_DC_rating;
conditionInfo(1).trialDuration = 4*32/85; % in sec - around 9.0353 (or 100*8/85 or 50*16/85)
conditionInfo(1).motion = 0; % by default, no motion 
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
conditionInfo(1).loc1 = 2; % xlocation of the 2nd stimulus IN ADDITION to the first stimulus
conditionInfo(1).loc2 = 4; % x coord of the 3rd stimulus IN ADDITION to the first stimulus
conditionInfo(1).horizBar = [0 0 conditionInfo(1).loc2+0.5 0.1];


% same parameters in all conditions
for cc=2:44
    conditionInfo(cc) = conditionInfo(1);
end
for cc=23:44
    conditionInfo(cc).xloc = -1; % eccentricity of stim centre from screen centre in deg
end

%% experimental manipulation

condNb = 1;

for repeat=1:2
    
% single stim condition
testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];
for testFq=1:length(testedFreq)
    for tt = 1:length(onTime)
        conditionInfo(condNb).stimTagFreq = testedFreq(testFq); 
        conditionInfo(condNb).dutyCycle = onTime(tt)/8;
        conditionInfo(condNb).label = [num2str(testedFreq(testFq),'%.1f') 'Hz ' num2str(onTime(tt)/8*100,'%.1f') '% DC'];
        condNb = condNb+1;
    end
end


testedFreq = [85/32 85/16 85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];
for tt = 1:length(testedFreq)
    conditionInfo(condNb).stimTagFreq = testedFreq(tt);
    conditionInfo(condNb).dutyCycle = onTime(tt)/8;
    conditionInfo(condNb).motion = 1;
    conditionInfo(condNb).label = ['motion ' num2str(testedFreq(tt),'%.1f') 'Hz ' num2str(onTime(tt)/8*100,'%.1f') '% DC'];
    condNb = condNb+1;
end

% other 50/50
conditionInfo(condNb).stimTagFreq = 85/32;
conditionInfo(condNb).dutyCycle = 4/8;
conditionInfo(condNb).motion = 1;
conditionInfo(condNb).label = ['motion ' num2str(85/32,'%.1f') 'Hz 50% DC'];
condNb = condNb+1;
conditionInfo(condNb).stimTagFreq = 85/16;
conditionInfo(condNb).dutyCycle = 4/8;
conditionInfo(condNb).motion = 1;
conditionInfo(condNb).label = ['motion ' num2str(85/16,'%.1f') 'Hz 50% DC'];
condNb = condNb+1;
end

end

