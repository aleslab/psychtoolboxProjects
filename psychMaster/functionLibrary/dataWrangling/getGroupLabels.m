function [ groupLabel ] = getGroupLabels( conditionInfo, groupingFieldname  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[ groupingIndices condIdex2GroupIndex ] = ...
    groupConditionsByField( conditionInfo, groupingFieldname );

nGroups = length(groupingIndices);

for iGroup = 1:nGroups,

    firstGroupCond = groupingIndices{iGroup}(1);
    
    %Grab the group label from the first condition in this group. 
    if isfield(conditionInfo(firstGroupCond),'groupLabel')
        groupLabel{iGroup} = conditionInfo(firstGroupCond).groupLabel;
    else
        %If the label doesn't exist let's make one:
    thisGroupValue = conditionInfo(firstGroupCond).(groupingFieldname);   
    groupLabel{iGroup} = [groupingFieldname ' = '...
        num2str(thisGroupValue,3)];
    end
    
end


end

