function [trialList] = makeTrialList(expInfo,conditionInfo)
%makeTrialList Creates a list for the trials.
%function [trialList] = makeTrialList(expInfo,conditionInfo)
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
%  randomizationOptions.blockByConditionField - [''] String containing the
%  name of the condition field to use for blocking. 
%
%   randomizationOptions =  a structure that is used to set various options
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
        
    case 'blocked'
        
        %Check If we're going to block by a field in the conditionInfo
        if isfield(expInfo,'randomizationOptions') ...
                && isfield(expInfo.randomizationOptions,'blockConditionsByField') ...
                && ~isempty(expInfo.randomizationOptions.blockConditionsByField)
        groupingFieldname = expInfo.randomizationOptions.blockConditionsByField;
        [ groupingIndices ] = groupConditionsByField( conditionInfo, groupingFieldname )
        else %Otherwise make 1 group containing all conditions.
            groupingIndices{1} = 1:nConditions;
        end
        
        %lets enumerate the total number of trials we need.
        %This type of loop construction where the index is incremented by
        %the loop is STRONGLY advised against. But I'm lazy and this works
        %Much more elegant and error-proof ways.
        idx = 1;        
        
        %
        %Now lets do a quick of the groups. This is an old way to accomplish a
        %permutation
        [~,permuteIdx]=sort(rand(size(groupingIndices)));
        groupingIndices = groupingIndices(permuteIdx);        
        
        %Loop over groups.
        for iGroup = 1: length(groupingIndices)
            
            %The condition list for this group.
            condList = groupingIndices{iGroup};
            %Now lets do a quick randomization. This is an old way to accomplish a
            %permutation
            [~,permuteIdx]=sort(rand(size(condList)));
            condList = condList(permuteIdx);
            
            %Not the really wierd use of: (:)'.  The (:) ensures a column
            %vector, the transpose '  makes it a row vector
            for iCond = condList(:)',
                
                for iRep = 1:conditionInfo(iCond).nReps,
                    trialList(idx) = iCond;
                    idx = idx+1;
                end
                
            end
        end
  
    case 'custom'
        disp('CUSTOM TRIAL ORDER NOT YET IMPLEMENTED JUST SHOWING FIRST TRIAL')
        trialList = 1;
end



