function [sortedTrialData] = organizeData(sessionInfo,experimentData)
% ORGANIZEDATA This function organizes the valid data from an experiment session 
%
% [sortedTrialData] = organizeData(sessionInfo,experimentData)
%
%  This function takes an experimental session and collects
%  all the repetitions of a condition together and removes any invalid
%  trials
%
%  Output:
%  sortedTrialData  = sortedTrialData(nConditions).trialData(nRepetitions)
%  The output is a multilevel structure with the first level collecting all
%  the different conditions. This contains the trialData for each
%  repition. The nested structure allows for different condition types and
%  repition numbers.
%                 

nCond = length(sessionInfo.conditionInfo);

repsPerCond = zeros(nCond,1); %Keep track of the valid repetitions per condition

for iTrial = 1:length(experimentData),
    
    thisCond = experimentData(iTrial).condNumber;
    
    %If this is NOT a valid trial skip it and move on.
    if ~experimentData(iTrial).validTrial || isempty(experimentData(iTrial).trialData)
        continue;
    end
    
    %Increment the reps by 1;
    repsPerCond(thisCond) = repsPerCond(thisCond) + 1;
    thisRep  = repsPerCond(thisCond);
    
    thisTrialData = experimentData(iTrial).trialData;
    thisTrialData.condNumber = thisCond;
    thisTrialData.trialNumber = iTrial;
    if isfield(sessionInfo,'trialToSessionIdx')
        thisTrialData.sessionIdx = sessionInfo.trialToSessionIdx(iTrial);
    end
    
    mergedData = updateStruct(experimentData(iTrial),thisTrialData);
    
    sortedTrialData(thisCond).trialData(thisRep) = thisTrialData;
    sortedTrialData(thisCond).condNumber = thisCond;
    sortedTrialData(thisCond).label = sessionInfo.conditionInfo(thisCond).label;
    
    sortedTrialData(thisCond).experimentData(thisRep) = mergedData;

    
end






