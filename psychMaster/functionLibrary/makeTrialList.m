function [trialList blockList] = makeTrialList(expInfo,conditionInfo)
%makeTrialList Creates a list for the trials.
% [trialList blockList] = makeTrialList(expInfo,conditionInfo)
%This code creates the trial list for the experiment
%It currently implements the following options set in expInfo:
%
%   randomizationType = ['random'] a short string that sets how trials are
%                      randomized it can take the following values:
%              'random' - fully randomize all conditions
%              'blocked' - repeatedly present a condition nReps time than
%                          switch conditions. Presents condition blocks
%                          in random order (e.g. 2 2 3 3 1 1). Defaults to
%                          blocking each individual condition. However you
%                          can block groups of conditions by using a field
%                          that groups conditions together in a block
%  randomizationOptions.blockByConditionField = [''] String containing the
%  name of the condition field to use for blocking. This will group
%  conditions together by the field
%  randomizationOptions.nBlockReps = [1] Number of times to repeat blocks.
%  Currently blocks are repeated as a group.
%  E.g.: Block rep 1: 2 1 3, Block rep 2: 3 2 1
%
%
%   randomizationOptions =  a structure that is used to set various options
%
% Outputs:
% trialsList = List of trial numbers
% blockList  = For blocked trials the block number for each trial. For
%              random we define all trials as block 1.

%  This code is currently fairly kludgy.  Just looping and building lists
%  of trials.  Which is starting to make it grow a bit cumbersome. At some point think about implementing more elegant
%  permutation code. -JMA
%

nConditions = length(conditionInfo);

switch lower(expInfo.randomizationType)
    
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
    case 'blocked'
        
        %Check If we're going to block by a field in the conditionInfo
        if isfield(expInfo,'randomizationOptions') ...
                && isfield(expInfo.randomizationOptions,'blockConditionsByField') ...
                && ~isempty(expInfo.randomizationOptions.blockConditionsByField)
            
            groupingFieldname = expInfo.randomizationOptions.blockConditionsByField;
            [ groupingIndices ] = groupConditionsByField( conditionInfo, groupingFieldname );
            
            if ~isfield(expInfo.randomizationOptions,'nBlockReps') ...
                || isempty(expInfo.randomizationOptions.nBlockReps)
                expInfo.randomizationOptions.nBlockReps = 1;
            end
            
        else %Otherwise make 1 group containing all conditions.
            groupingIndices{1} = 1:nConditions;
            expInfo.randomizationOptions.nBlockReps = 1;
        end
        
        %lets enumerate the total number of trials we need. This type of
        %loop construction where we just concatenate and grow things will
        %nilly is STRONGLY advised against. But I'm lazy and this works
        %Much more elegant and error-proof ways.
        trialList = [];
        blockList = [];
        
        
        %repeat everything for each block repeat
        blockIdx = 1;
        for iBlockRep = 1:expInfo.randomizationOptions.nBlockReps,
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
        
    case 'custom'
        disp('CUSTOM TRIAL ORDER NOT YET IMPLEMENTED JUST SHOWING FIRST TRIAL')
        trialList = 1;
end



