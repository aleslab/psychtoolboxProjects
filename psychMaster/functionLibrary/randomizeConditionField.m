function [ condInfo ] = randomizeConditionField( condInfo )
%randomizeConditionField Handles randomize values in the condition field
%for each trial
%function [ condInfo ] = randomizeConditionField( condInfo )
% This function handles implementing randomizing an aspect of a
%                     condition on each trial. It is a structure with as
%                     many entries as fields to randomize.  For each entry
%                     the following values determine the randomization:
%                        fieldname = a string indicating which field to randomize 
%                        type = ['gaussian'] or 'uniform','custom'
%                        param = For gaussian it is the mean and
%                        standard deviation, For uniform it's the upper and
%                        lower bounds. If 'custom' it is a handle to the
%                        function to call to generate the random value.


%If nothing to do return.
if isempty(condInfo.randomizeField)
    return
end


nFields = length(condInfo.randomizeField);
            
for iName = 1:nFields
    fieldname = condInfo.randomizeField(iName).fieldname;
    
    switch lower(condInfo.randomizeField(iName).type)
        case 'gaussian'
            mu = condInfo.randomizeField(iName).param(1);
            sigma = condInfo.randomizeField(iName).param(1);
            thisRand = randn()*sigma+mu;
             
        case 'uniform'
            lowerBound = condInfo.randomizeField(iName).param(1);
            upperBound = condInfo.randomizeField(iName).param(2);                        
            thisRand = rand()*(upperBound-lowerBound) + lowerBound;
            
        case 'custom'
            thisRand = condInfo.randomizeField(iName).param;
    end
    
    condInfo.(fieldname) = thisRand;
end
    

end

