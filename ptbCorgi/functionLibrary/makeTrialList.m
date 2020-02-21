function [trialList, blockList] = makeTrialList(expInfo,conditionInfo)
%makeTrialList Creates a list for the trials.
% [trialList blockList] = makeTrialList(expInfo,conditionInfo)
%This code creates the trial list for the experiment
%It currently implements the following options set in the
%expInfo.trialRandomization structure:
%
%   type = ['random'] a short string that sets how trials are
%          randomized it can take the following values:
%          'random'  - fully randomize order of all conditions
%          'blocked' - Block single/groups of conditions together. Can
%                      block either a group of conditions together, or
%                      single conditions.
%          'markov'  - Conditions randomized according to a markov chain
%    'blockedMarkov' - Allows specifying different markov chain probabilities
%                      in each block.  This is fairly complex. 
%          'custom'  - Predfined custom trial sequence.
%
%
%  'Blocked' Type Extra fields:
%  blockByField = [expInfo.conditionGroupingField] A string containing the
%  name of the condition field to use for blocking. If the paradigm sets a
%  condition grouping this defaults to using that grouping.  Otherwise it
%  blocks individual conditions together (e.g. 1 1 1 3 3 3 3 2 2 2).
%
%  nBlockReps = [1] Number of times to repeat blocks.
%  Currently blocks are repeated as a group.
%  E.g.: Block rep 1: 221133, Block rep 2: 332211
%
%  'markov' type extra fields:
%  
%  transitionMatrix - [no default] Matrix specifying transition
%                     probabilities.  Rows specify the current condition,
%                     columns for the next condition. For example if
%                     condition 1 always goes to 2, 2 always to 3, 3 has
%                     80% chance of 1, and 20% of 2, 0% staying 3 use: 
%                     [ 0  1  0; ...
%                       0  0  1; ...
%                      .8 .2  0 ]
%                     The transition matrix -MUST- have as many rows and
%                     columns as conditions in the paradigm.
%  nTrials          - Number of trials
%                     
%  
%  'blockedMarkov' type fields:
%   Blocked markov is complex and takes care. Be especially careful with
%   condition lists. But this mode allows powerful trial order design. One
%   use is to change the probabilities during the experiment.
%
%   markovInfo - A structure with as many entries as different groupings.
%   markovInfo(iGroup).conditionList    - list of conditions to include in
%                this block. !!IMPORTANT: The order of this list is also used
%                for the transitionMatrix!
%   markovInfo(iGroup).transitionMatrix - specific transition probailities
%                                        for the conditions in this block
%   markovInfo(iGroup).nTrials - How many trials for this block.
%
%   groupOrder - This can be either the string 'random' or a a list
%                specifying the order to present the above defined grouping
%                (e.g. [ 1 1 1 2 2 2])
%   nBlockReps - Only used if markovList is 'random' how many times to
%                repeat each grouping. 
%
%  'Custom' Type extra fields:
%  trialList  = [No Default]  A list of condition numbers to present in
%                sequence (e.g. [1 2 3 3 2 1]);
%
%  blockList  = [ones(size(trialList))]  A list indentifying which (if any)
%               block the trial belongs to. Should be monotonicly increasing.
%
% Outputs:
% trialsList = List of trial numbers
% blockList  = For blocked trials the block number for each trial. For
%              random we define all trials as block 1.
%
%  Examples:
%  The default is just to present trials in random order, which corresponds
%  to:
%  expInfo.trialRandomization.type = 'random';
%
%  Say we have an experiment with 5 total conditions organized in 2 groups:
%  1,2,3 are 10% contrast, 4,5 are 50% contrast, and each condition is set
%  to repeat 2 times (nReps=2)  The following code would present block
%  using contrast:
%
%  expInfo.trialRandomization.type = 'blocked';
%  expInfo.trialRandomization.blockByField = 'contrast';
%  expInfo.trialRandomization.nBlockReps   = 2;
%
%  Result in a trial order, for example:
%  [4 5 5 4 (block end) 1 2 1 3 3 2 (block end) 5 5 4 4 (block end) 3 3 2 1 1 2]
%
%  Blocked Markov Example:
% 
%  Say we have the same 5 conditions in 2 groups as above and we never want
%  to repeat a stimulus:
%  expInfo.trialRandomization.type = 'blockedMarkov'
%  markovInfo(1).conditionList = [1 2 3];
%  markovInfo(1).transitionMatrix = [0 .5 .5; .5 0 .5; .5 .5 0];
%  markovInfo(1).nTrials = 6;
%  markovInfo(2).conditionList = [4 5];
%  markovInfo(2).transitionMatrix = [0 1; 1 0];
%  markovInfo(2).nTrials = 4;
%  expInfo.trialRandomization.markovInfo = markovInfo;
%  expInfo.trialRandomization.groupOrder = [2 1 2 1]; % Say
% 
%  Results in example trial order:
%  [4 5 4 5 3 2 1 2 3 1 5 4 5 4 3 1 3 2 1 2]
%
%


%  This code is currently fairly kludgy.  Just looping and building lists
%  of trials.  Which is starting to make it grow a bit cumbersome. At some
%  point think about implementing more elegant permutation code. -JMA
%

nConditions = length(conditionInfo);

if isfield(expInfo, 'randomizationType')
    expInfo.trialRandomization.type = expInfo.randomizationType;
    
end

%
if isfield(expInfo, 'randomizationOptions')  && ~isempty(expInfo.randomizationOptions)      
    %Old style
     if isfield(expInfo.randomizationOptions,'blockConditionsByField')
         expInfo.trialRandomization.blockByField = expInfo.randomizationOptions.blockConditionsByField;
     end
     
     
     expInfo.trialRandomization = updateStruct(expInfo.trialRandomization, expInfo.randomizationOptions);                
end

randomization = expInfo.trialRandomization;

switch lower(randomization.type)
    
    case 'random'
        
        %lets enumerate the total number of trials we need.
        %This type of loop construction where the index is incremented by
        %the loop is STRONGLY advised against. But I'm lazy and this works
        %Much more elegant and error-proof ways.
        idx = 1;
        for iCond = 1:nConditions,
            
            for iRep = 1:conditionInfo(iCond).nReps,
                trialList(idx) = iCond;
                idx = idx+1;
            end
            
        end
        
        %Now lets do a quick randomization. This is an old way to accomplish a
        %permutation
        [~,idx]=sort(rand(size(trialList)));
        trialList = trialList(idx);
        blockList = ones(size(trialList));
    case 'custom' %Custom allows user specification.
        
        if ~isfield(randomization,'trialList')
            error('ptbCorgi:makeTrialList:missingField','Custom trial randomization requires trialList field to be set');            
        end
        
        trialList = randomization.trialList;
        blockList = ones(size(trialList)); %Default to one block. 
        if isfield(randomization,'blockList') && ~isempty(randomization.blockList)
            blockList = randomization.blockList;
        end
        
    case 'blocked'
        
        
        %If user didn't set a specific randomization grouping field. But
        %set the conditionGrouping field.  Default to using the
        %conditionGroupingField.
        if ~isfield(randomization,'blockByField') ...
                && isfield(expInfo,'conditionGroupingField')
            randomization.blockByField = expInfo.conditionGroupingField;
        end
        
        %Check If we're going to block by a field in the conditionInfo
        if isfield(randomization,'blockByField') ...
                && ~isempty(randomization.blockByField)
            
            groupingFieldname = randomization.blockByField;
            [ groupingIndices ] = groupConditionsByField( conditionInfo, groupingFieldname );            
        
        
        else %Otherwise make groups that each contain only a single condition.
            for iCond = 1:nConditions,
                groupingIndices{iCond} = iCond;
            end
        end
        
        %If block reps is not set default to 1. 
        if ~isfield(randomization,'nBlockReps') ...
                || isempty(randomization.nBlockReps)
            randomization.nBlockReps = 1;
        end
        
        %lets enumerate the total number of trials we need. This type of
        %loop construction where we just concatenate and grow things will
        %nilly is STRONGLY advised against. But I'm lazy and this works
        %Much more elegant and error-proof ways.
        trialList = [];
        blockList = [];
        
        %repeat everything for each block repeat
        blockIdx = 1;
        for iBlockRep = 1:randomization.nBlockReps,
            %
            %Now lets do a quick of the groups. This is an old way to accomplish a
            %permutation
            [~,permuteIdx]=sort(rand(size(groupingIndices)));
            groupingIndices = groupingIndices(permuteIdx);
            
            %Loop over groups.
            for iGroup = 1: length(groupingIndices)
                
                %The condition list for this group.
                condList = groupingIndices{iGroup};
                
                %Now we're going to build up the the condition list for this
                %block. Respecting the "nReps" field from the condition Info.
                %Note the really wierd use of: (:)'.  The (:) ensures a column
                %vector, the transpose '  makes it a row vector. This is in
                %case the condList in the cell array is not the right way
                %round.
                blockTrialIdx = 1;
                for iCond = condList(:)',
                    
                    for iRep = 1:conditionInfo(iCond).nReps,
                        thisBlockTrialList(blockTrialIdx) = iCond;
                        blockTrialIdx = blockTrialIdx+1;
                    end
                    
                end
                
                %Now for this block we've got an ordered and repeated list.
                %We're going to randomize it for this block and add it to the
                %trial list.
                [permuteIdx]=randperm(length(thisBlockTrialList));
                thisBlockTrialList = thisBlockTrialList(permuteIdx);
                
                %Now grow the trialList and BlockList
                trialList = [trialList thisBlockTrialList];
                blockList = [blockList blockIdx*ones(size(thisBlockTrialList))];
                blockIdx = blockIdx+1;
            end
        end    
        
        
    case 'markov'           
        trialList = generateMarkovSequence(randomization.nTrials,randomization.transitionMatrix);
        blockList = ones(size(trialList));
        
    case 'blockedmarkov'
        %This is a crazy seciont
        nGroups = length(randomization.markovInfo);
        
        %See how to ra
        if ischar(randomization.groupOrder)
            if strcmpi(randomization.groupOrder,'random')
               
                %Repeat the group ids nBlcokReps times
                groupOrder=repmat(1:nGroups,1,randomization.nBlockReps);                
                %Nuts nesting of things to achieve random permutation of
                %the group order. 
                groupOrder = groupOrder(randperm(length(groupOrder)));
                
                
            else
                error('Unkown groupOrder');
            end
        else
            groupOrder = randomization.groupOrder;
        end
        
        
        nBlocks = length(groupOrder);


        %Build up trial order, 
        trialList = [];
        blockList = [];
        for iBlock = 1:nBlocks,
            
            %Pull out the specific markovian parameters for this block
            thisGroup = groupOrder(iBlock);%W
            transMatrix = randomization.markovInfo(thisGroup).transitionMatrix;
            nTrials     = randomization.markovInfo(thisGroup).nTrials;
            thisTrialList = generateMarkovSequence(nTrials,transMatrix);
            
            %Now translate trials into condition indices.
            thisTrialList = randomization.markovInfo(thisGroup).conditionList(thisTrialList);
            trialList = [trialList thisTrialList];
            blockList = [blockList iBlock*ones(size(thisTrialList))];
        end
        
    otherwise
        error('Unkown trialRandomization.type')
        
    
end



