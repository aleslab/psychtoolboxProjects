function [ trialData ] = validateConditions( trialData )
%validateTrialData Ensures that the trial structure has required fields
%   This function checks to see if all required fields are set in the trial
%   structure. If not it sets things to a default value 


%list of required fields and default values:
fieldListCommon = {...
'validTrial',true;...
'feedbackMsg','';...
};  


    
checkFields(fieldListCommon)
    
    




%Nested function to check the structure. NOTE: Nested functions have access
%to the whole function workspace. 
function checkFields(fieldList)

nField = size(fieldList,1);
    for iField = 1:nField,
        
        if ~isfield(trialData,fieldList{iField,1})
            disp(['Trial structure is missing field: "' fieldList{iField,1} '"'...
                ' setting to default value: "' num2str(fieldList{iField,2}) '"']);
           trialData.(fieldList{iField,1}) = fieldList{iField,2};
           
           trialData.validateChangedFields = true;
        elseif isempty(trialData.(fieldList{iField,1}))
            trialData.(fieldList{iField,1}) = fieldList{iField,2};
            trialData.validateChangedFields = true;
        end
    end
end

end



