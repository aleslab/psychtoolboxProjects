function [ groupingIndices ] = groupConditionsByField( conditionInfo, groupingFieldname )
%groupConditionsByField Creates cell-array that groups conditions
%   Detailed explanation goes here





[v ia ic] = unique( [conditionInfo.(groupingFieldname)]);

nGroups = length(v);

for iGroup = 1:nGroups,
    
    groupingIndices{iGroup} = find(ic==iGroup);
end

end

