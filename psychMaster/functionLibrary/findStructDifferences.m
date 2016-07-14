function [ names ] = findStructDifferences( s1, s2 )
%findStructDifferences Compare structures for differences
%   function [ names ] = findStructDifferences( s1, s2 )
%
%   Compares structures s1 and s2 and returns the names of any fields in
%   s1 that have different values from those in s2.
%   Does not return names of fields inside substructures, but compares the
%   structures recursively. 
allNames = fieldnames(s1);

names = {};

if length(s1)>1 || length(s2)>1
    error('Only able to compare length 1 structures currently')
end

for iName = 1:length(allNames),
    
    thisField = allNames{iName};
    
    
        
    if ~isfield(s2,thisField)
        names{end+1} = thisField;
    elseif isstruct( s1.(thisField) ) % A little recursion to find if any substructures are different
        subNames = findStructDifferences( s1.(thisField), s2.(thisField) );
        
        if ~isempty(subNames)
            names{end+1} = thisField;
        end
        
    elseif ~isequal(s1.(thisField),s2.(thisField))
        names{end+1} = thisField;
    end
    
end



end

