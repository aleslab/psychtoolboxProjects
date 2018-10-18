function outputStruct  = validateFields(inputStruct, fieldDefault)

if isempty(inputStruct)
    inputStruct = [];
end

outputStruct = inputStruct;

if ~iscell(fieldDefault)
    error('fieldDefault must be cell array of key,value pairs');
end

%The following is for forcing input into a known format. 
%accept 2d or 1d cell by making 2d array 1d by 
fieldDefault = fieldDefault(:); %Force input to be column vector
nFields = length(fieldDefault)/2; 

%Check for correct for paired input
if rem(nFields,1)>0 
    error('fieldDefault is not paired, missing a key or value');
end

fieldDefault = reshape(fieldDefault,2,nFields)'; %Reshape into 2d cell. 

for iField = 1:nFields,
    %If a field is either missing or empty set to the default. 
    if ~isfield(inputStruct,fieldDefault{iField,1})
        outputStruct.(fieldDefault{iField,1}) = fieldDefault{iField,2};
    elseif isempty(inputStruct.(fieldDefault{iField,1}))
        outputStruct.(fieldDefault{iField,1}) = fieldDefault{iField,2};
    end
end

