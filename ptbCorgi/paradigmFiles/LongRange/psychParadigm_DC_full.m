function [conditionInfo, expInfo] = psychParadigm_DC_full(expInfo)

KbName('UnifyKeyNames');

%paradigmName is what will be prepended to data files
expInfo.paradigmName = 'DC_full';
expInfo.trialRandomization.type = 'blocked';
expInfo.trialRandomization.blockByField = 'xloc'; % or just have a field group for each condition to determine which condition is in which group. Here xloc is the same for all conditions so all conditions are in each block
expInfo.trialRandomization.nBlockReps   = 9; % 9; 

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


%%% GABOR
% my_gabor = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient);
radiusPix = 6;
expInfo.my_gabor = createGabor(radiusPix, radiusPix/2, 1, 1, 0, 0);
expInfo.counter_gabor = createGabor(radiusPix, radiusPix/2, 1, 1, 180, 0);
expInfo.gaborStim = [0 0 radiusPix-1 radiusPix]; % in deg


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
conditionInfo(1).stimSize = [0 0 0.5 8]; % in deg
conditionInfo(1).xloc = 5 ; % eccentricity of stim centre from screen centre in deg
conditionInfo(1).yloc = 0; % y eccentricity of stim centre
conditionInfo(1).trialFun=@trial_DC_full;
conditionInfo(1).trialDuration = 8*32/85; % in sec
conditionInfo(1).xMotion = 0.6; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)




% same parameters in all conditions
for cc=2:60
    conditionInfo(cc) = conditionInfo(1);
end


%% experimental manipulation

condNb = 1;
    
testedFreq = [85/8 85/16 85/32]; % in Hz this is the onset of the single stimulus
onTime = [1 2 4 6 7];

for stype = 1:2
    for mot = 1:2
    for testFq=1:length(testedFreq)
        for tt = 1:length(onTime)
            conditionInfo(condNb).motion = mot-1;
            conditionInfo(condNb).stimType = stype;
            conditionInfo(condNb).stimTagFreq = testedFreq(testFq);
            conditionInfo(condNb).dutyCycle = onTime(tt)/8;
            conditionInfo(condNb).label = ['S' num2str(stype) num2str(mot)  'f' num2str(testedFreq(testFq),'%.0f') 'on' num2str(onTime(tt)/8*100,'%.0f') '%'];
            condNb = condNb+1;
        end
    end
    end
end


end

