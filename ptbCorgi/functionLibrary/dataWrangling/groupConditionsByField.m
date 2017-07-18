function [ groupingIndices condIndex2GroupIndex] = groupConditionsByField( conditionInfo, groupingFieldname )
%groupConditionsByField Creates cell-array that groups conditions
%   Detailed explanation goes here
%[ groupingIndices condIndex2GroupIndex] = groupConditionsByField( conditionInfo, groupingFieldname )

[v ia ic] = unique( [conditionInfo.(groupingFieldname)]);

condIndex2GroupIndex = ic;

nGroups = length(v);

for iGroup = 1:nGroups,
    
    groupingIndices{iGroup} = find(ic==iGroup);        
end

end

