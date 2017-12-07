function [ names ] = findStructDifferences( s1, s2 )
%findStructDifferences Compare structures for differences
%   [ names ] = findStructDifferences( s1, s2 )
%
%   Compares structures s1 and s2 and returns the names of any fields in
%   s1 that have different values from those in s2.
%   Does not return names of fields inside substructures, but compares the
%   structures recursively.
%
%   Inputs:
%   s1,s2 - Two structures to compare. 
%
%   Output:
%   names - A cell array containing the names of all fields that contain
%   differences. 

allNames = fieldnames(s1);

names = {};

%If structures are a different sizes then we are going to define them as 
%everything is different
if ~isequal(size(s1),size(s2))
    names = allNames;
    return;
end

% if length(s1)>1 || length(s2)>1
%     error('Only able to compare length 1 structures currently')
% end


for iEl = 1:numel(s1),
    
    for iName = 1:length(allNames),
        
        thisField = allNames{iName};
        
        
        
        if ~isfield(s2(iEl),thisField)
            names{end+1} = thisField;
        elseif isstruct( s1(iEl).(thisField) ) % A little recursion to find if any substructures are different
            subNames = findStructDifferences( s1(iEl).(thisField), s2(iEl).(thisField) );
            
            if ~isempty(subNames)
                names{end+1} = thisField;
            end
            
            %Note: isequaln() is a very useful function
        elseif ~isequaln(s1(iEl).(thisField),s2(iEl).(thisField))
            names{end+1} = thisField;
        end
        
    end
end

names = unique(names);


end

