function [ outputMatrix, dimensionLabels ] = buildMatrixFromField(fieldname, varargin )
%buildMatrixFromField Extracts ptbCorgi data and organizes it as a matrix
%function [ outputMatrix, dimensionLabels ] = buildMatrixFromField( fieldname, [see below] )

%   
%  Input:
%  fieldname: a string identify the field to be extracted. E.g.:
%             fieldname = 'validTrial';
%             fieldname = 'isResponseCorrect';
%
%  There are 4 ways to specify the input data:
%   1) ptbCorgiData structure as returned by ptbCorgiDataBrowser or similar
%      [outputMatrix] = buildMatrixFromField('validTrial',ptbCorgiData) 
%
%   2) A session filename (either single or a concatenated session):
%      [outputMatrix] = buildMatrixFromField('validTrial','myExp_ppt_20170101.mat') 
%
%   3) A cell array of session files:
%      fileList = {'/path/to/data1.mat' ...
%                    '/path/to/data2.mat' };
%      [outputMatrix] = buildMatrixFromField('validTrial',fileList);
%
%   4) Using the contents of a session file:
%      [nC nT] = buildMatrixFromField('validTrial',sessionInfo,experimentData) 
%
%
%  Output:
%  outputMatrix is a matrix ithat is sized:
%  
%  Extracted data size x nTrial x nCondition x nParticipant
%
%  If the data to extract is a matrix it is returned as a vector
%
%  For numeric data:
%  If any of the data is missing it is filled with NaN. Therefore when
%  using the matrix be sure to check for NaN values. Matlab contains
%  several functions for this for example nanmean, nansum, nanstd
%
%  For string data:
%  If any of the data is missing it is padded by spaces.
%
%  dimensionLabels is a cell array containing labels for outputMatrix
%  dimensions. Mostly usefull for the condition labels and participantIds.
%  Dimensions 1 and 2 currently are just vectors as long as the data. 


%Load data if we need to.
ptbCorgiData = overloadOpenPtbCorgiData(varargin{:});
%number of participants to loop over. 
nParticipants = ptbCorgiData.nParticipants;

if ~isstr(fieldname)
    error('Fieldname input must be a string')
end


%Let's initialize the matrix
%Now different conditions/participants may have different numbers of trials.
%So as a quick and dirty init for now just initialize with the number of
%trials from the first participant, and first condition.
nTrialsInit = length(ptbCorgiData.participantData(1).sortedTrialData(1).experimentData);
outputMatrix = NaN(1,nTrialsInit,ptbCorgiData.nConditions,nParticipants);
allClassNames = {};

for iPpt = 1:nParticipants,
    
    
    %If the data hasn't been sorted already, lets sort it
    if ~isfield( ptbCorgiData.participantData(1),'sortedTrialData')
        
        thisSortedData = organizeData(ptbCorgiData.participantData(iPpt).sessionInfo,...
            ptbCorgiData.participantData(iPpt).experimentData);
    
    %otherwise just use the sorted data
    else
        thisSortedData = ptbCorgiData.participantData(iPpt).sortedTrialData;
    end
    
    dimensionLabels{4}{iPpt} = ptbCorgiData.participantList{iPpt};
    
    %Now go through each condition.
    for iCond = 1:ptbCorgiData.nConditions
        
        thisExperimentData = thisSortedData(iCond).experimentData;
           
        if ~isfield(thisExperimentData,fieldname)
            warning('ptbCorgi:buildmatrix:missingField',...
                'Skipping Condition %s because it does not contain %s', ...
                ptbCorgiData.conditionInfo(iCond).label, fieldname)
            continue;
        end

            dimensionLabels{3}{iCond} = ptbCorgiData.conditionInfo(iCond).label;

            
        %Now go through each trial
        for iTrial = 1:length(thisExperimentData),
            
            
            thisField = thisExperimentData(iTrial).(fieldname);
            %Turn thisField into a column vector to simplify concatenating
            %possibly different sized matrices together.
            thisFieldClassName = class(thisField);
            
            thisField = thisField(:);
            %If our matrix isn't large enough extend it for this data
            if size(outputMatrix,1) < length(thisField);
                
                %If it's not the first time through the loop print a
                %warning if the matrix changes size.
                if ~(iPpt ==1 && iCond ==1 && iTrial ==1)
                    warning('ptbCorgi:buildmatrix:diffSize',...
                        'Extracted data from participant: %s, condition: %i, trial: %i has more data, padding rest of matrix with NaN',...
                        ptbCorgiData.participantList{iPpt},iCond,iTrial);
                end
                
                sizeNeededToExtend = length(thisField) - size(outputMatrix,1);
                outputMatrix(end+1:length(thisField),:,:,:) = ...
                    NaN(sizeNeededToExtend,size(outputMatrix,2),ptbCorgiData.nConditions,nParticipants);
            end
        
            
            %Finaly put the data into the output matrix.
            outputMatrix(1:length(thisField),iTrial,iCond,iPpt) = thisField;
            allClassNames{end+1} = thisFieldClassName;
        end
        
    end
end

dimensionLabels{1} = 1:size(outputMatrix,1);
dimensionLabels{2} = 1:size(outputMatrix,2);

allClassNames = unique(allClassNames);

%if multiple datatypes are encountered result may be correct. But should
%warn users because it could get funny
if length(allClassNames)>1
    warning('ptbCorgi:buildmatrix:diffClass',...
        'Extracted data had multiple types, take care final data may be unexpected. Loaded types: %s',...
        allClassNames);
end

%if we loaded a string or char convert it to a more useful space padded
%char matrix instead of numeric nan padded
if strcmp(allClassNames,'char')
    nanIdx = isnan(outputMatrix(:));
    outputMatrix(nanIdx) = 32;
    outputMatrix = char(outputMatrix);
end

end

