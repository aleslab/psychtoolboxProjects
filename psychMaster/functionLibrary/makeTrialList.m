function [trialList] = makeTrialList(expInfo,conditionInfo)
%makeTrialList Creates a list for the trials.
%function [trialList] = makeTrialList(expInfo,conditionInfo)
%This code creates the trial list for the experiment
%It currently implements the following options set 
%
%expInfo.

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
        
        
        %lets enumerate the total number of trials we need.
        %This type of loop construction where the index is incremented by
        %the loop is STRONGLY advised against. But I'm lazy and this works
        %Much more elegant and error-proof ways.
        idx = 1;        
        condList = 1:nConditions;        
        %Now lets do a quick randomization. This is an old way to accomplish a
        %permutation
        [~,idx]=sort(rand(size(condList)));
        condList = condList(idx);        
        
        for iCond = condList,                        
            for iRep = 1:conditionInfo(iCond).nReps,
                trialList(idx) = iCond;
                idx = idx+1;
            end
            
        end
        
  
    case 'custom'
        disp('CUSTOM TRIAL ORDER NOT YET IMPLEMENTED JUST SHOWING FIRST TRIAL')
        trialList = 1;
end



