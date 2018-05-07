function outputStruct  = validateFields(inputStruct, fieldDefaults)
%validateFields - Helper function to set defaults for empty/missing fields
%outputStruct  = validateFields(inputStruct, fieldDefault)
%
%Helper function to simplify setting settinf default fields in structures.
%Uses a cell array of key/value pairs to define default values for fields.
%Then if a structure doesn't have these set or they are empty sets the
%field to the value specified
%
%
%Inputs:
%
% inputStruct - Input structure to 
%
% fieldDefaults - Cell array contain key/value pairs for setting up the
%                 structure.  Each key must be a string that specifies a
%                 valid fieldname, each key must be followed by a value.
%                 E.g. {'key1',1,'key2',2,}
%
%Example:
%structToSetup = struct(); 
%defaults  = {'fieldname1',1,'myOtherField',3};
%
%structToSetup = validateFields(structToSetup,defaults);
%
% Results in: 
% structToSetup = 
% 
%       fieldname1: 1
%     myOtherField: 3



if isempty(inputStruct)
    inputStruct = [];
end

outputStruct = inputStruct;

if ~iscell(fieldDefaults)
    error('fieldDefault must be cell array of key,value pairs');
end

%The following is for forcing input into a known format. 
%accept 2d or 1d cell by making 2d array 1d by 
fieldDefaults = fieldDefaults(:); %Force input to be column vector
nFields = length(fieldDefaults)/2; 

%Check for correct for paired input
if rem(nFields,1)>0 
    error('fieldDefault is not paired, missing a key or value');
end

fieldDefaults = reshape(fieldDefaults,2,nFields)'; %Reshape into 2d cell. 

for iField = 1:nFields,
    
    %If a field is either missing or empty set to the default. 
    if ~isfield(inputStruct,fieldDefaults{iField,1}) ...
            || isempty(inputStruct.(fieldDefaults{iField,1}))
        [outputStruct.(fieldDefaults{iField,1})] = deal(fieldDefaults{iField,2});
    end
end

