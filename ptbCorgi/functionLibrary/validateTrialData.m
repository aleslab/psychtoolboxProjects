function [ trialData ] = validateTrialData( trialData )
%validateTrialData Ensures that the trial structure has required fields
%[ trialData ] = validateConditions( trialData )
%
%   This function checks to see if all required fields are set in the
%   trialData structure. If not it sets things to a default value.


%list of required fields and default values:
fieldListCommon = {...
'validTrial',true;... %Trials are valid unless something says they aren't
'feedbackMsg','';...  %This is here incase feedback is turned on but no message is set
};  


    
checkFields(fieldListCommon)
    
    




%Nested function to check the structure. NOTE: Nested functions have access
%to the whole function workspace. 
function checkFields(fieldList)

nField = size(fieldList,1);
    for iField = 1:nField,
        
        if ~isfield(trialData,fieldList{iField,1})
            %Disable display of warning message because it's not very
            %useful to end users usually.
%             disp(['Trial structure is missing field: "' fieldList{iField,1} '"'...
%                 ' setting to default value: "' num2str(fieldList{iField,2}) '"']);
           trialData.(fieldList{iField,1}) = fieldList{iField,2};
           
           trialData.validateChangedFields = true;
        elseif isempty(trialData.(fieldList{iField,1}))
            trialData.(fieldList{iField,1}) = fieldList{iField,2};
            trialData.validateChangedFields = true;
        end
    end
end

end



