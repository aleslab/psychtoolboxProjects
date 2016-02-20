function [ names ] = findStructDifferences( s1, s2 )
%findStructDifferences Compare structures for differences
%   function [ names ] = findStructDifferences( s1, s2 )
%
%   Compares structures s1 and s2 and returns the names of any fields in
%   s1 that have different values from those in s2.

allNames = fieldnames(s1);

names = {};
for iName = 1:length(allNames),
    
    thisField = allNames{iName};
    
    if ~isfield(s2,thisField)     
        names{end+1} = thisField;
    elseif ~isequal(s1.(thisField),s2.(thisField))
        names{end+1} = thisField;
    end
    
end



end

