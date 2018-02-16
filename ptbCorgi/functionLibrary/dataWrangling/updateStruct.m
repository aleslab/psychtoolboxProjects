function [ mergedStruct ] = updateStruct( intoStruct, fromStruct )
%updateStruct Updates a structure with new fields and values 
%[ mergedStruct] = updateStruct( intoStruct, fromStruct )
%
%   Update structure is used when you have two disparate structures you
%   wnat to merge into one structure. WARNING: Values in intoStruct will be
%   overwritten by values in fromStruct if fieldnames are the same. Does
%   not work for array of structures, only single-element
%
%   Usage: [mergedStruct] = updateStruct(intoStruct,fromStruct) Takes the
%   fields from "fromStruct" and adds them to "intoStruct". If a fieldnames
%   are
%    
%   intoStruct = Single element structure we will be adding/changing.
%   fromStruct = Single element structure we are taking from.
%
%   mergedStruct = output combined structure.


%-- input checking here --%

%First lets do some empty handling. Some variable can be initialized with
%[] instead of struct().  We want to treat an empty matrix the same as an
%empty struct. So something is empty turn it into an empty struct
if isempty(fromStruct)
    fromStruct = struct();    
end

if isempty(intoStruct)
    intoStruct = struct();    
end

if ~isstruct(intoStruct) || ~isstruct(fromStruct)
   error('ptbCorgi:updateStruct:inputError', 'Inputs must be structures') 
end

if length(intoStruct) ~=1 || length(fromStruct) ~= 1
    error('ptbCorgi:updateStruct:inputError', 'Inputs must have length 1') 
end


%These are the fields we are taking from.
fromFieldnames = fieldnames(fromStruct);

%The into struct is what we start with an update
mergedStruct = intoStruct;

for iField = 1:length(fromFieldnames),
    
    %Use dynamic field names to update the into struct.
    %This will add a field if it doesn't exist, or take the value from
    %"fromStruct" if it does exist. 
    thisFieldname = fromFieldnames{iField};
    mergedStruct.(thisFieldname) = fromStruct.(thisFieldname);
    
end



end

