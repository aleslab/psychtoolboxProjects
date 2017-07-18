function [ condInfo ] = randomizeConditionField( condInfo )
%randomizeConditionField Handles randomize values in the condition field
%
%function [ condInfo ] = randomizeConditionField( condInfo )
% This function handles implementing randomizing an aspect of a condition
% on each trial. It looks at the randomizeField entry in condInfo and uses
% that to modify the selected options in condInfo.
%
% condInfo.randomizeField is a structure with as many entries as fields to
% randomize.  For each entry the following values determine the
% randomization: 
% fieldname = a string indicating which field to randomize
% type = ['gaussian'] or 'uniform','custom' 
% param = For gaussian it is the mean and standard deviation e.g. [0 1], 
%         For uniform it's the upper and lower bounds, e.g. [1 6].
%         If 'custom' it is a handle to the function to call to generate the random
%         value. e.g. @myRand
%
%Example:
%To choose a random orientation from 0 to 360 on each trial:
%condInfo.randomizeField.fieldname = 'orientation'
%condInfo.randomizeField.type      = 'uniform'
%condInfo.randomizeField.param     = [0 360]
%
%To randomize orientation and also add a random contrast from a gaussian
%with a mean of .5 and a standard deviation of .05:
%condInfo.randomizeField(1).fieldname = 'orientation'
%condInfo.randomizeField(1).type      = 'uniform'
%condInfo.randomizeField(1).param     = [0 360]
%condInfo.randomizeField(2).fieldname = 'contrast'
%condInfo.randomizeField(2).type      = 'gaussian'
%condInfo.randomizeField(2).param     = [.5 .05]



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

